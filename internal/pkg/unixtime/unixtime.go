package unixtime

import (
	"encoding/json"
	"fmt"
	"strconv"
	"strings"
	"time"
)

//ДАНИЛ Я НАДЕЮСЬ ТЕБЕ ТАКИХ ПОДСКАЗОК ХВАТИТ
//ЗДЕСЬ КОРОЧЕ БЛОК СО ВРЕМЕНЕМ КОТОРЫЙ ФОРМАТИРУЕТ ГОЛАНГОВСКОЕ АХУЕННОЕ РАСПРЕДЕЛЕНИЕ НА ТВОЮ ХУЙНЮ

type UnixTime int64

func New(t time.Time) UnixTime {
	return UnixTime(t.Unix())
}

func NewPtr(t *time.Time) *UnixTime {
	if t == nil {
		return nil
	}

	v := UnixTime(t.Unix())
	return &v
}

func FromUnix(v int64) UnixTime {
	return UnixTime(v)
}

func FromUnixPtr(v *int64) *UnixTime {
	if v == nil {
		return nil
	}

	value := UnixTime(*v)
	return &value
}

func Now() UnixTime {
	return UnixTime(time.Now().UTC().Unix())
}

func (t UnixTime) Time() time.Time {
	return time.Unix(int64(t), 0).UTC()
}

func (t UnixTime) Unix() int64 {
	return int64(t)
}

func (t UnixTime) MarshalJSON() ([]byte, error) {
	return []byte(strconv.FormatInt(int64(t), 10)), nil
}

func (t *UnixTime) UnmarshalJSON(data []byte) error {
	raw := strings.TrimSpace(string(data))

	if raw == "null" {
		return nil
	}

	raw = strings.Trim(raw, `"`)

	v, err := strconv.ParseInt(raw, 10, 64)
	if err != nil {
		return fmt.Errorf("unixtime: invalid timestamp %q: %w", raw, err)
	}

	if v < 0 {
		return fmt.Errorf("unixtime: timestamp must be greater than or equal to 0")
	}

	*t = UnixTime(v)

	return nil
}

var _ json.Marshaler = UnixTime(0)
var _ json.Unmarshaler = (*UnixTime)(nil)
