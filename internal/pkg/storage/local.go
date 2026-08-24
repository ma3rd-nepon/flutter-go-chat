package storage

import (
	"errors"
	"fmt"
	"io"
	"mime"
	"mime/multipart"
	"os"
	"path/filepath"
	"strings"

	"github.com/google/uuid"
)

var (
	ErrFileTooLarge    = errors.New("file too large")
	ErrUnsupportedFile = errors.New("unsupported file type")
	ErrEmptyFile       = errors.New("empty file")
)

type LocalStorage struct {
	baseDir string
	baseURL string
}

func NewLocalStorage(baseDir string) *LocalStorage {
	return &LocalStorage{
		baseDir: baseDir,
		baseURL: "/uploads",
	}
}

func (s *LocalStorage) Save(
	subdir string,
	file multipart.File,
	header *multipart.FileHeader,
	allowedExtensions map[string]string,
	maxSize int64,
) (url string, originalFilename string, kind string, mimeType string, sizeBytes int64, err error) {
	if header == nil || header.Size == 0 {
		return "", "", "", "", 0, ErrEmptyFile
	}

	if header.Size > maxSize {
		return "", "", "", "", 0, ErrFileTooLarge
	}

	ext := strings.ToLower(filepath.Ext(header.Filename))

	fileKind, ok := allowedExtensions[ext]
	if !ok {
		return "", "", "", "", 0, ErrUnsupportedFile
	}

	mimeType = mime.TypeByExtension(ext)
	if mimeType == "" {
		mimeType = "application/octet-stream"
	}

	uploadPath := filepath.Join(s.baseDir, subdir)

	if err := os.MkdirAll(uploadPath, 0o755); err != nil {
		return "", "", "", "", 0, fmt.Errorf("create upload dir: %w", err)
	}

	newName := uuid.NewString() + ext
	fullPath := filepath.Join(uploadPath, newName)

	dst, err := os.Create(fullPath)
	if err != nil {
		return "", "", "", "", 0, fmt.Errorf("create file: %w", err)
	}

	defer dst.Close()

	written, err := io.CopyN(dst, file, maxSize+1)
	if written > maxSize {
		_ = os.Remove(fullPath)
		return "", "", "", "", 0, ErrFileTooLarge
	}

	if err != nil && err != io.EOF {
		_ = os.Remove(fullPath)
		return "", "", "", "", 0, fmt.Errorf("write file: %w", err)
	}

	if written == 0 {
		_ = os.Remove(fullPath)
		return "", "", "", "", 0, ErrEmptyFile
	}

	url = s.baseURL + "/" + subdir + "/" + newName

	return url, header.Filename, fileKind, mimeType, header.Size, nil
}
