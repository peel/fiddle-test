module github.com/peel/fiddle-test

go 1.24

// bumped to clear CVE-2025-30204 (golang-jwt/jwt/v4 before v4.5.2)
require github.com/golang-jwt/jwt/v4 v4.5.2
