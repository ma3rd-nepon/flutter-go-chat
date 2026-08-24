package response

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5/middleware"
)

type Meta struct {
	RequestID string `json:"request_id"`
	Timestamp int64  `json:"timestamp"`
}

type ErrorDetail struct {
	Field string `json:"field,omitempty"`
	Issue string `json:"issue"`
}

type ErrorPayload struct {
	Code    string        `json:"code"`
	Message string        `json:"message"`
	Details []ErrorDetail `json:"details,omitempty"`
}

type Body struct {
	Success bool          `json:"success"`
	Data    any           `json:"data"`
	Error   *ErrorPayload `json:"error"`
	Meta    Meta          `json:"meta"`
}

type Pagination struct {
	Limit   int     `json:"limit"`
	Cursor  *string `json:"cursor"`
	HasMore bool    `json:"has_more"`
}

type List struct {
	Items      any        `json:"items"`
	Pagination Pagination `json:"pagination"`
}

func NewList(items any, limit int, cursor *string, hasMore bool) List {
	return List{
		Items: items,
		Pagination: Pagination{
			Limit:   limit,
			Cursor:  cursor,
			HasMore: hasMore,
		},
	}
}

func WriteJSON(
	w http.ResponseWriter,
	r *http.Request,
	status int,
	data any,
	errPayload *ErrorPayload,
) {
	requestID := middleware.GetReqID(r.Context())

	body := Body{
		Success: errPayload == nil,
		Data:    data,
		Error:   errPayload,
		Meta: Meta{
			RequestID: requestID,
			Timestamp: time.Now().UTC().Unix(),
		},
	}

	if requestID != "" {
		w.Header().Set("X-Request-ID", requestID)
	}

	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)

	_ = json.NewEncoder(w).Encode(body)
}

func OK(w http.ResponseWriter, r *http.Request, data any) {
	WriteJSON(w, r, http.StatusOK, data, nil)
}

func Created(w http.ResponseWriter, r *http.Request, data any) {
	WriteJSON(w, r, http.StatusCreated, data, nil)
}

func Fail(
	w http.ResponseWriter,
	r *http.Request,
	status int,
	code string,
	message string,
	details []ErrorDetail,
) {
	WriteJSON(w, r, status, nil, &ErrorPayload{
		Code:    code,
		Message: message,
		Details: details,
	})
}

func BadRequest(w http.ResponseWriter, r *http.Request, code string, message string) {
	Fail(w, r, http.StatusBadRequest, code, message, nil)
}

func Unauthorized(w http.ResponseWriter, r *http.Request, message string) {
	Fail(w, r, http.StatusUnauthorized, "unauthorized", message, nil)
}

func Forbidden(w http.ResponseWriter, r *http.Request, message string) {
	Fail(w, r, http.StatusForbidden, "forbidden", message, nil)
}

func NotFound(w http.ResponseWriter, r *http.Request, message string) {
	Fail(w, r, http.StatusNotFound, "not_found", message, nil)
}

func Conflict(w http.ResponseWriter, r *http.Request, message string) {
	Fail(w, r, http.StatusConflict, "conflict", message, nil)
}

func MethodNotAllowed(w http.ResponseWriter, r *http.Request, message string) {
	Fail(w, r, http.StatusMethodNotAllowed, "method_not_allowed", message, nil)
}

func Internal(w http.ResponseWriter, r *http.Request) {
	Fail(w, r, http.StatusInternalServerError, "internal_error", "Internal server error", nil)
}
