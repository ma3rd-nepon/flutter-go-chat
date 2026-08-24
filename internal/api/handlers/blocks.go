package handlers

import (
	"encoding/json"
	"errors"
	"net/http"

	"github.com/google/uuid"

	"supernova/internal/api/dto"
	"supernova/internal/api/middleware"
	"supernova/internal/api/response"
	"supernova/internal/service"
)

type BlockHandler struct {
	blocks *service.BlockService
}

func NewBlockHandler(blocks *service.BlockService) *BlockHandler {
	return &BlockHandler{
		blocks: blocks,
	}
}

func (h *BlockHandler) Block(w http.ResponseWriter, r *http.Request) {
	blockerID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	var req dto.BlockRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	if req.UserID == uuid.Nil {
		response.BadRequest(w, r, "validation_error", "user_id is required")
		return
	}

	block, err := h.blocks.Block(r.Context(), blockerID, req.UserID)
	if err != nil {
		if errors.Is(err, service.ErrCannotBlockSelf) {
			response.BadRequest(w, r, "validation_error", "cannot block yourself")
			return
		}

		if errors.Is(err, service.ErrUserNotFound) {
			response.NotFound(w, r, "user not found")
			return
		}

		response.Internal(w, r)
		return
	}

	response.OK(w, r, dto.NewBlockResponse(block))
}

func (h *BlockHandler) Unblock(w http.ResponseWriter, r *http.Request) {
	blockerID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	var req dto.UnblockRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	if req.UserID == uuid.Nil {
		response.BadRequest(w, r, "validation_error", "user_id is required")
		return
	}

	if err := h.blocks.Unblock(r.Context(), blockerID, req.UserID); err != nil {
		if errors.Is(err, service.ErrCannotBlockSelf) {
			response.BadRequest(w, r, "validation_error", "cannot unblock yourself")
			return
		}

		response.Internal(w, r)
		return
	}

	response.OK(w, r, dto.NewUnblockResponse(req.UserID))
}

func (h *BlockHandler) List(w http.ResponseWriter, r *http.Request) {
	blockerID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	limit := parseLimit(r, 20, 100)

	items, err := h.blocks.List(r.Context(), blockerID, limit)
	if err != nil {
		response.Internal(w, r)
		return
	}

	blockedUsers := make([]dto.BlockedUserResponse, 0, len(items))

	for _, item := range items {
		blockedUsers = append(blockedUsers, dto.NewBlockedUserResponse(item))
	}

	response.OK(w, r, response.NewList(blockedUsers, limit, nil, false))
}
