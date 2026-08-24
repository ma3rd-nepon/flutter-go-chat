package handlers

import (
	"net"
	"net/http"
	"strconv"
	"strings"
)

func parseLimit(r *http.Request, defaultLimit int, maxLimit int) int {
	limit := defaultLimit

	raw := r.URL.Query().Get("limit")
	if raw == "" {
		return limit
	}

	parsed, err := strconv.Atoi(raw)
	if err != nil {
		return limit
	}

	if parsed <= 0 {
		return limit
	}

	if parsed > maxLimit {
		return maxLimit
	}

	return parsed
}

func clientIP(r *http.Request) string {
	if ip := strings.TrimSpace(r.Header.Get("X-Real-Ip")); ip != "" {
		if net.ParseIP(ip) != nil {
			return ip
		}
	}

	if xff := r.Header.Get("X-Forwarded-For"); xff != "" {
		parts := strings.Split(xff, ",")
		ip := strings.TrimSpace(parts[0])

		if net.ParseIP(ip) != nil {
			return ip
		}
	}

	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		if net.ParseIP(r.RemoteAddr) != nil {
			return r.RemoteAddr
		}

		return ""
	}

	if net.ParseIP(host) != nil {
		return host
	}

	return ""
}
