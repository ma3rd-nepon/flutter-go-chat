package dto

type RegisterRequest struct {
	Email       string  `json:"email" validate:"required,email,max=254"`
	Password    string  `json:"password" validate:"required,min=8,max=72"`
	DisplayName string  `json:"display_name" validate:"required,min=1,max=64"`
	Username    *string `json:"username" validate:"omitempty,min=3,max=32"`
}

type LoginRequest struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required"`
}

type RefreshRequest struct {
	RefreshToken string `json:"refresh_token" validate:"required"`
}

type LogoutRequest struct {
	RefreshToken string `json:"refresh_token" validate:"required"`
}
