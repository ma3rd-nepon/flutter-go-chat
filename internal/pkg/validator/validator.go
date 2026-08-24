package validator

import (
	"errors"
	"fmt"
	"reflect"
	"strings"

	validatorlib "github.com/go-playground/validator/v10"
)

type FieldError struct {
	Field string `json:"field"`
	Issue string `json:"issue"`
}

type Validator struct {
	validate *validatorlib.Validate
}

func New() *Validator {
	v := validatorlib.New()

	v.RegisterTagNameFunc(func(fld reflect.StructField) string {
		name := strings.SplitN(fld.Tag.Get("json"), ",", 2)[0]
		if name == "" || name == "-" {
			return fld.Name
		}

		return name
	})

	return &Validator{
		validate: v,
	}
}

func (v *Validator) Struct(s any) []FieldError {
	err := v.validate.Struct(s)
	if err == nil {
		return nil
	}

	var validationErrors validatorlib.ValidationErrors
	if errors.As(err, &validationErrors) {
		fieldErrors := make([]FieldError, 0, len(validationErrors))

		for _, fe := range validationErrors {
			fieldErrors = append(fieldErrors, FieldError{
				Field: fe.Field(),
				Issue: issueMessage(fe),
			})
		}

		return fieldErrors
	}

	return []FieldError{
		{
			Field: "_",
			Issue: err.Error(),
		},
	}
}

func issueMessage(fe validatorlib.FieldError) string {
	switch fe.Tag() {
	case "required":
		return "is required"
	case "email":
		return "invalid email"
	case "min":
		return fmt.Sprintf("must be at least %s", fe.Param())
	case "max":
		return fmt.Sprintf("must be at most %s", fe.Param())
	case "len":
		return fmt.Sprintf("must have length %s", fe.Param())
	case "hexcolor":
		return "invalid hex color"
	case "uuid":
		return "invalid uuid"
	case "oneof":
		return fmt.Sprintf("must be one of: %s", fe.Param())
	default:
		return fmt.Sprintf("failed %q validation", fe.Tag())
	}
}
