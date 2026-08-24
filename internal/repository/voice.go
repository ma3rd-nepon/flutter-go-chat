package repository

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"supernova/internal/domain"
)

var ErrVoiceChannelNotFound = errors.New("voice channel not found")

type VoiceRepository struct {
	db *pgxpool.Pool
}

func NewVoiceRepository(db *pgxpool.Pool) *VoiceRepository {
	return &VoiceRepository{db: db}
}

func (r *VoiceRepository) Create(ctx context.Context, channel *domain.VoiceChannel) error {
	if channel.ID == uuid.Nil {
		channel.ID = uuid.New()
	}

	now := time.Now().UTC()

	if channel.CreatedAt.IsZero() {
		channel.CreatedAt = now
	}

	channel.UpdatedAt = now

	if channel.Bitrate == 0 {
		channel.Bitrate = 64000
	}

	_, err := r.db.Exec(ctx, `
		INSERT INTO voice_channels (
			id,
			chat_id,
			name,
			bitrate,
			max_participants,
			created_at,
			updated_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7
		)
	`,
		channel.ID,
		channel.ChatID,
		channel.Name,
		channel.Bitrate,
		channel.MaxParticipants,
		channel.CreatedAt,
		channel.UpdatedAt,
	)

	if err != nil {
		return fmt.Errorf("create voice channel: %w", err)
	}

	return nil
}

func (r *VoiceRepository) GetByID(ctx context.Context, channelID uuid.UUID) (*domain.VoiceChannel, error) {
	row := r.db.QueryRow(ctx, `
		SELECT
			id,
			chat_id,
			name,
			bitrate,
			max_participants,
			created_at,
			updated_at
		FROM voice_channels
		WHERE id = $1
	`, channelID)

	var channel domain.VoiceChannel

	err := row.Scan(
		&channel.ID,
		&channel.ChatID,
		&channel.Name,
		&channel.Bitrate,
		&channel.MaxParticipants,
		&channel.CreatedAt,
		&channel.UpdatedAt,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, ErrVoiceChannelNotFound
		}

		return nil, fmt.Errorf("get voice channel: %w", err)
	}

	return &channel, nil
}

func (r *VoiceRepository) ListParticipants(ctx context.Context, channelID uuid.UUID) ([]domain.VoiceParticipant, error) {
	rows, err := r.db.Query(ctx, `
		SELECT
			channel_id,
			user_id,
			joined_at,
			muted,
			deafened
		FROM voice_participants
		WHERE channel_id = $1
		ORDER BY joined_at
	`, channelID)

	if err != nil {
		return nil, fmt.Errorf("list voice participants: %w", err)
	}

	defer rows.Close()

	participants := make([]domain.VoiceParticipant, 0, 32)

	for rows.Next() {
		var participant domain.VoiceParticipant

		if err := rows.Scan(
			&participant.ChannelID,
			&participant.UserID,
			&participant.JoinedAt,
			&participant.Muted,
			&participant.Deafened,
		); err != nil {
			return nil, fmt.Errorf("scan voice participant: %w", err)
		}

		participants = append(participants, participant)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("voice participant rows error: %w", err)
	}

	return participants, nil
}

func (r *VoiceRepository) CountParticipants(ctx context.Context, channelID uuid.UUID) (int, error) {
	var count int

	err := r.db.QueryRow(ctx, `
		SELECT count(*)
		FROM voice_participants
		WHERE channel_id = $1
	`, channelID).Scan(&count)

	if err != nil {
		return 0, fmt.Errorf("count voice participants: %w", err)
	}

	return count, nil
}

func (r *VoiceRepository) IsParticipant(ctx context.Context, channelID uuid.UUID, userID uuid.UUID) (bool, error) {
	var exists bool

	err := r.db.QueryRow(ctx, `
		SELECT EXISTS(
			SELECT 1
			FROM voice_participants
			WHERE channel_id = $1 AND user_id = $2
		)
	`, channelID, userID).Scan(&exists)

	if err != nil {
		return false, fmt.Errorf("check voice participant: %w", err)
	}

	return exists, nil
}

func (r *VoiceRepository) AddParticipant(ctx context.Context, participant domain.VoiceParticipant) error {
	if participant.JoinedAt.IsZero() {
		participant.JoinedAt = time.Now().UTC()
	}

	_, err := r.db.Exec(ctx, `
		INSERT INTO voice_participants (
			channel_id,
			user_id,
			joined_at,
			muted,
			deafened
		) VALUES (
			$1, $2, $3, $4, $5
		)
		ON CONFLICT (channel_id, user_id)
		DO UPDATE SET
			joined_at = EXCLUDED.joined_at,
			muted = false,
			deafened = false
	`,
		participant.ChannelID,
		participant.UserID,
		participant.JoinedAt,
		participant.Muted,
		participant.Deafened,
	)

	if err != nil {
		return fmt.Errorf("add voice participant: %w", err)
	}

	return nil
}

func (r *VoiceRepository) RemoveParticipant(ctx context.Context, channelID uuid.UUID, userID uuid.UUID) error {
	_, err := r.db.Exec(ctx, `
		DELETE FROM voice_participants
		WHERE channel_id = $1 AND user_id = $2
	`, channelID, userID)

	if err != nil {
		return fmt.Errorf("remove voice participant: %w", err)
	}

	return nil
}
