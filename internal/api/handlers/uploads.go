package handlers

import (
	"errors"
	"mime/multipart"
	"net/http"

	"supernova/internal/api/dto"
	"supernova/internal/api/middleware"
	"supernova/internal/api/response"
	"supernova/internal/pkg/storage"
	"supernova/internal/service"
	"supernova/internal/ws"
)

type UploadHandler struct {
	uploads *service.UploadService
	events  *service.EventService
}

func NewUploadHandler(uploads *service.UploadService, events *service.EventService) *UploadHandler {
	return &UploadHandler{
		uploads: uploads,
		events:  events,
	}
}

func (h *UploadHandler) UploadAvatar(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	file, header, err := formFile(w, r)
	if err != nil {
		response.BadRequest(w, r, "validation_error", "file is required")
		return
	}

	defer file.Close()

	url, err := h.uploads.UploadAvatar(r.Context(), meID, file, header)
	if err != nil {
		writeUploadError(w, r, err)
		return
	}

	response.OK(w, r, dto.UploadResponse{
		URL: url,
	})
}

func (h *UploadHandler) UploadBanner(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	file, header, err := formFile(w, r)
	if err != nil {
		response.BadRequest(w, r, "validation_error", "file is required")
		return
	}

	defer file.Close()

	url, err := h.uploads.UploadBanner(r.Context(), meID, file, header)
	if err != nil {
		writeUploadError(w, r, err)
		return
	}

	response.OK(w, r, dto.UploadResponse{
		URL: url,
	})
}

func (h *UploadHandler) UploadChatAvatar(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	chatID, err := uuidParam(r, "chatID")
	if err != nil {
		response.BadRequest(w, r, "validation_error", "invalid chat id")
		return
	}

	file, header, err := formFile(w, r)
	if err != nil {
		response.BadRequest(w, r, "validation_error", "file is required")
		return
	}

	defer file.Close()

	view, err := h.uploads.UploadChatAvatar(r.Context(), chatID, meID, file, header)
	if err != nil {
		writeUploadError(w, r, err)
		return
	}

	chatResponse := dto.NewChatResponse(view)
	updatedChatID := view.Chat.ID

	h.events.BroadcastChatEvent(
		r.Context(),
		updatedChatID,
		nil,
		ws.NewEvent(ws.EventChatUpdated, &updatedChatID, map[string]any{
			"chat": chatResponse,
		}),
	)

	url := ""
	if view.Chat.AvatarURL != nil {
		url = *view.Chat.AvatarURL
	}

	response.OK(w, r, dto.UploadResponse{
		URL: url,
	})
}

func (h *UploadHandler) UploadAttachment(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	chatID, err := uuidParam(r, "chatID")
	if err != nil {
		response.BadRequest(w, r, "validation_error", "invalid chat id")
		return
	}

	file, header, err := formFile(w, r)
	if err != nil {
		response.BadRequest(w, r, "validation_error", "file is required")
		return
	}

	defer file.Close()

	result, err := h.uploads.UploadAttachment(r.Context(), chatID, meID, file, header)
	if err != nil {
		writeUploadError(w, r, err)
		return
	}

	response.Created(w, r, dto.AttachmentUploadResponse{
		ID:        result.ID,
		URL:       result.URL,
		Filename:  result.Filename,
		MimeType:  result.MimeType,
		SizeBytes: result.SizeBytes,
		Kind:      result.Kind,
	})
}

func formFile(w http.ResponseWriter, r *http.Request) (multipart.File, *multipart.FileHeader, error) {
	if err := r.ParseMultipartForm(32 << 20); err != nil {
		return nil, nil, err
	}

	return r.FormFile("file")
}

func writeUploadError(w http.ResponseWriter, r *http.Request, err error) {
	switch {
	case errors.Is(err, storage.ErrFileTooLarge):
		response.Fail(w, r, http.StatusRequestEntityTooLarge, "file_too_large", err.Error(), nil)
		return

	case errors.Is(err, storage.ErrUnsupportedFile),
		errors.Is(err, storage.ErrEmptyFile):
		response.BadRequest(w, r, "validation_error", err.Error())
		return

	case errors.Is(err, service.ErrUserNotFound),
		errors.Is(err, service.ErrChatNotFound):
		response.NotFound(w, r, "not found")
		return

	case errors.Is(err, service.ErrForbidden):
		response.Forbidden(w, r, "forbidden")
		return

	default:
		response.Internal(w, r)
		return
	}
}
