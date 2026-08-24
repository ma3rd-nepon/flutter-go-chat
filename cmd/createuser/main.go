package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/joho/godotenv"

	"supernova/internal/pkg/hasher"
)

func main() {
	_ = godotenv.Load()

	if len(os.Args) < 3 {
		fmt.Println("Usage:")
		fmt.Println("  go run ./cmd/createuser <email> <password> [username]")
		fmt.Println("")
		fmt.Println("Example:")
		fmt.Println("  go run ./cmd/createuser user123@example.com password123 user123")
		os.Exit(1)
	}

	email := strings.ToLower(strings.TrimSpace(os.Args[1]))
	password := os.Args[2]

	username := ""
	if len(os.Args) >= 4 {
		username = strings.TrimSpace(os.Args[3])
	}

	displayName := username
	if displayName == "" {
		parts := strings.Split(email, "@")
		displayName = parts[0]
	}

	passwordHasher := hasher.NewPasswordHasher()

	passwordHash, err := passwordHasher.Hash(password)
	if err != nil {
		log.Fatalf("failed to hash password: %v", err)
	}

	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		log.Fatal("DATABASE_URL is empty, check .env")
	}

	ctx := context.Background()

	conn, err := pgx.Connect(ctx, databaseURL)
	if err != nil {
		log.Fatalf("failed to connect to database: %v", err)
	}

	defer conn.Close(ctx)

	var emailExists bool

	err = conn.QueryRow(
		ctx,
		`SELECT EXISTS(SELECT 1 FROM users WHERE lower(email) = lower($1))`,
		email,
	).Scan(&emailExists)

	if err != nil {
		log.Fatalf("failed to check email: %v", err)
	}

	if emailExists {
		log.Fatalf("email already exists: %s", email)
	}

	if username != "" {
		var usernameExists bool

		err = conn.QueryRow(
			ctx,
			`SELECT EXISTS(SELECT 1 FROM users WHERE lower(username) = lower($1))`,
			username,
		).Scan(&usernameExists)

		if err != nil {
			log.Fatalf("failed to check username: %v", err)
		}

		if usernameExists {
			log.Fatalf("username already exists: %s", username)
		}
	}

	id := uuid.New()
	now := time.Now().UTC()

	var usernamePtr *string
	if username != "" {
		usernamePtr = &username
	}

	_, err = conn.Exec(
		ctx,
		`
		INSERT INTO users (
			id,
			email,
			password_hash,
			username,
			display_name,
			status,
			created_at,
			updated_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8
		)
		`,
		id,
		email,
		passwordHash,
		usernamePtr,
		displayName,
		"offline",
		now,
		now,
	)

	if err != nil {
		log.Fatalf("failed to insert user: %v", err)
	}

	fmt.Println("✅ User created")
	fmt.Println("ID:       ", id)
	fmt.Println("Email:    ", email)
	fmt.Println("Password: ", password)

	if username != "" {
		fmt.Println("Username: ", username)
	}
}
