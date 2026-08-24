package main

import (
	"testing"
	"time"
)

func TestASignedTokenCarriesItsSubject(t *testing.T) {
	signed, err := issue("alice", time.Now())
	if err != nil {
		t.Fatalf("signing failed: %v", err)
	}

	subject, err := subjectOf(signed)
	if err != nil {
		t.Fatalf("parsing failed: %v", err)
	}
	if subject != "alice" {
		t.Fatalf("subject was %q, want %q", subject, "alice")
	}
}

func TestAnExpiredTokenIsRefused(t *testing.T) {
	signed, err := issue("bob", time.Now().Add(-2*time.Hour))
	if err != nil {
		t.Fatalf("signing failed: %v", err)
	}

	if _, err := subjectOf(signed); err == nil {
		t.Fatal("an expired token was accepted")
	}
}
