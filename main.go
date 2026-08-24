package main

import (
	"fmt"
	"os"
	"time"

	jwt "github.com/golang-jwt/jwt/v4"
)

const secret = "fiddle-test-not-a-real-secret"

func issue(subject string, now time.Time) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.RegisteredClaims{
		Subject:   subject,
		IssuedAt:  jwt.NewNumericDate(now),
		ExpiresAt: jwt.NewNumericDate(now.Add(time.Hour)),
	})
	return token.SignedString([]byte(secret))
}

func subjectOf(signed string) (string, error) {
	claims := jwt.RegisteredClaims{}
	_, err := jwt.ParseWithClaims(signed, &claims, func(*jwt.Token) (any, error) {
		return []byte(secret), nil
	})
	if err != nil {
		return "", err
	}
	return claims.Subject, nil
}

func main() {
	signed, err := issue("fiddle", time.Now())
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	subject, err := subjectOf(signed)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Println(subject)
}
