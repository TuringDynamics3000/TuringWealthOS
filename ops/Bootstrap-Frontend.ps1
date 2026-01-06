# ============================================================
# Bootstrap-Frontend.ps1
# One-shot: minimal Next.js frontend bootstrap
# PowerShell-only | Safe | Idempotent
# ============================================================

$ErrorActionPreference = "Stop"

$RepoRoot = "C:\Users\mjmil\TuringDeploy\TuringWealthOS"

Write-Host ""
Write-Host "============================================================"
Write-Host "BOOTSTRAPPING MINIMAL NEXT.JS FRONTEND"
Write-Host "============================================================"
Write-Host ""

Set-Location $RepoRoot

# ------------------------------------------------------------
# 1) Create package.json if missing
# ------------------------------------------------------------

if (!(Test-Path "package.json")) {
@'
{
  "name": "turingwealthos",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start"
  },
  "dependencies": {
    "next": "14.1.0",
    "react": "18.2.0",
    "react-dom": "18.2.0",
    "swr": "2.2.4"
  }
}
'@ | Out-File -LiteralPath "package.json" -Encoding utf8 -Force

Write-Host "✓ package.json created"
} else {
Write-Host "✓ package.json already exists"
}

# ------------------------------------------------------------
# 2) next.config.js
# ------------------------------------------------------------

if (!(Test-Path "next.config.js")) {
@'
/** @type {import("next").NextConfig} */
const nextConfig = {
  reactStrictMode: true
};
module.exports = nextConfig;
'@ | Out-File -LiteralPath "next.config.js" -Encoding utf8 -Force

Write-Host "✓ next.config.js created"
}

# ------------------------------------------------------------
# 3) tsconfig.json
# ------------------------------------------------------------

if (!(Test-Path "tsconfig.json")) {
@'
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": false,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve"
  },
  "include": ["src"]
}
'@ | Out-File -LiteralPath "tsconfig.json" -Encoding utf8 -Force

Write-Host "✓ tsconfig.json created"
}

# ------------------------------------------------------------
# 4) Minimal src/pages scaffold
# ------------------------------------------------------------

New-Item -ItemType Directory -Force -Path "src\pages" | Out-Null

if (!(Test-Path "src\pages\_app.tsx")) {
@'
export default function App({ Component, pageProps }) {
  return <Component {...pageProps} />;
}
'@ | Out-File -LiteralPath "src\pages\_app.tsx" -Encoding utf8 -Force

Write-Host "✓ _app.tsx created"
}

if (!(Test-Path "src\pages\index.tsx")) {
@'
export default function Home() {
  return (
    <div style={{ padding: "2rem" }}>
      <h1>TuringWealthOS</h1>
      <p>Frontend is running.</p>
    </div>
  );
}
'@ | Out-File -LiteralPath "src\pages\index.tsx" -Encoding utf8 -Force

Write-Host "✓ index.tsx created"
}

# ------------------------------------------------------------
# 5) Install dependencies
# ------------------------------------------------------------

if (Get-Command pnpm -ErrorAction SilentlyContinue) {
  Write-Host "→ Installing dependencies with pnpm"
  pnpm install
} elseif (Get-Command npm -ErrorAction SilentlyContinue) {
  Write-Host "→ Installing dependencies with npm"
  npm install
} else {
  throw "No package manager found (pnpm or npm required)"
}

Write-Host ""
Write-Host "============================================================"
Write-Host "✓ FRONTEND BOOTSTRAP COMPLETE"
Write-Host "============================================================"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  pwsh -NoExit ops/Start-Dev-And-Open-Demo.ps1"
Write-Host ""
Write-Host "No shell termination."
Write-Host ""
