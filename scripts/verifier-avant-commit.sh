#!/usr/bin/env sh
# Optional pre-commit hook: refuse commits that include vault content.
# Install: cp scripts/verifier-avant-commit.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
staged=$(git diff --cached --name-only --diff-filter=ACMR \
  | grep -E '^(reunions|personnes|projets|bilans|boite-de-reception|state|config)/' \
  | grep -vE '(^|/)\.gitkeep$|^state/README\.md$|^config/vault\.example\.yaml$')
if [ -n "$staged" ]; then
  echo "Commit refusé : contenu du coffre détecté."
  echo "$staged"
  exit 1
fi
