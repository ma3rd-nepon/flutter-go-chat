package service

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/repository"
)

var (
	ErrCannotFriendSelf      = errors.New("cannot friend self")
	ErrAlreadyFriends        = errors.New("already friends")
	ErrFriendRequestNotFound = errors.New("friend request not found")
)

type FriendService struct {
	friends *repository.FriendRepository
	users   *repository.UserRepository
}

func NewFriendService(
	friends *repository.FriendRepository,
	users *repository.UserRepository,
) *FriendService {
	return &FriendService{
		friends: friends,
		users:   users,
	}
}

func (s *FriendService) Request(ctx context.Context, requesterID uuid.UUID, addresseeID uuid.UUID) (domain.Friend, bool, error) {
	if requesterID == addresseeID {
		return domain.Friend{}, false, ErrCannotFriendSelf
	}

	_, err := s.users.GetByID(ctx, addresseeID.String())
	if err != nil {
		if errors.Is(err, repository.ErrUserNotFound) {
			return domain.Friend{}, false, ErrUserNotFound
		}

		return domain.Friend{}, false, err
	}

	existing, err := s.friends.GetPair(ctx, requesterID, addresseeID)
	if err != nil {
		return domain.Friend{}, false, err
	}

	if existing != nil {
		switch {
		case existing.Status == domain.FriendStatusAccepted:
			return domain.Friend{}, false, ErrAlreadyFriends

		case existing.Status == domain.FriendStatusPending && existing.RequesterID == addresseeID:
			if err := s.friends.UpdateStatus(ctx, existing.ID, domain.FriendStatusAccepted); err != nil {
				return domain.Friend{}, false, err
			}

			existing.Status = domain.FriendStatusAccepted
			existing.UpdatedAt = time.Now().UTC()

			return *existing, false, nil

		case existing.Status == domain.FriendStatusPending && existing.RequesterID == requesterID:
			return *existing, false, nil

		default:
			if err := s.friends.Delete(ctx, requesterID, addresseeID); err != nil {
				return domain.Friend{}, false, err
			}
		}
	}

	now := time.Now().UTC()

	friend := domain.Friend{
		ID:          uuid.New(),
		RequesterID: requesterID,
		AddresseeID: addresseeID,
		Status:      domain.FriendStatusPending,
		CreatedAt:   now,
		UpdatedAt:   now,
	}

	if err := s.friends.Create(ctx, &friend); err != nil {
		return domain.Friend{}, false, err
	}

	return friend, true, nil
}

func (s *FriendService) Accept(ctx context.Context, meID uuid.UUID, otherID uuid.UUID) (domain.Friend, error) {
	if meID == otherID {
		return domain.Friend{}, ErrCannotFriendSelf
	}

	existing, err := s.friends.GetPair(ctx, meID, otherID)
	if err != nil {
		return domain.Friend{}, err
	}

	if existing == nil {
		return domain.Friend{}, ErrFriendRequestNotFound
	}

	if existing.Status == domain.FriendStatusAccepted {
		return *existing, nil
	}

	if existing.Status == domain.FriendStatusPending &&
		existing.RequesterID == otherID &&
		existing.AddresseeID == meID {

		if err := s.friends.UpdateStatus(ctx, existing.ID, domain.FriendStatusAccepted); err != nil {
			return domain.Friend{}, err
		}

		existing.Status = domain.FriendStatusAccepted
		existing.UpdatedAt = time.Now().UTC()

		return *existing, nil
	}

	return domain.Friend{}, ErrFriendRequestNotFound
}

func (s *FriendService) Reject(ctx context.Context, meID uuid.UUID, otherID uuid.UUID) (domain.Friend, error) {
	if meID == otherID {
		return domain.Friend{}, ErrCannotFriendSelf
	}

	existing, err := s.friends.GetPair(ctx, meID, otherID)
	if err != nil {
		return domain.Friend{}, err
	}

	if existing == nil {
		return domain.Friend{}, ErrFriendRequestNotFound
	}

	if existing.Status == domain.FriendStatusPending &&
		existing.RequesterID == otherID &&
		existing.AddresseeID == meID {

		if err := s.friends.UpdateStatus(ctx, existing.ID, domain.FriendStatusDeclined); err != nil {
			return domain.Friend{}, err
		}

		existing.Status = domain.FriendStatusDeclined
		existing.UpdatedAt = time.Now().UTC()

		return *existing, nil
	}

	return domain.Friend{}, ErrFriendRequestNotFound
}

func (s *FriendService) Remove(ctx context.Context, meID uuid.UUID, otherID uuid.UUID) error {
	if meID == otherID {
		return ErrCannotFriendSelf
	}

	return s.friends.Delete(ctx, meID, otherID)
}

func (s *FriendService) List(ctx context.Context, meID uuid.UUID, limit int) ([]domain.FriendUser, error) {
	return s.friends.ListFriends(ctx, meID, limit)
}

func (s *FriendService) Requests(ctx context.Context, meID uuid.UUID, direction string, limit int) ([]domain.FriendUser, error) {
	if direction != "incoming" && direction != "outgoing" {
		direction = "incoming"
	}

	return s.friends.ListRequests(ctx, meID, direction, limit)
}
