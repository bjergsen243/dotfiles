#!/usr/bin/env node
// Claude Code Statusline — Starship-themed edition
// Mirrors your Starship palette (cyan/blue/yellow) and JetBrainsMono Nerd Font glyphs.
// Features: context intelligence, quota tracking, branch awareness.

const fs = require('fs');
const path = require('path');
const os = require('os');
const { execFileSync } = require('child_process');

// ── Starship-aligned palette (from your starship.toml) ──────────────────────
// Using ANSI codes that match your Starship bold cyan/blue/yellow theme.
const C = {
  cyan:    '\x1b[1;36m',   // bold cyan  — branches, prompt (matches [character] & [git_branch])
  blue:    '\x1b[1;34m',   // bold blue  — directories (matches [directory])
  yellow:  '\x1b[1;33m',   // bold yellow — warnings, duration (matches [cmd_duration], [git_status])
  green:   '\x1b[1;32m',   // healthy
  orange:  '\x1b[38;5;208m', // caution
  red:     '\x1b[1;31m',   // danger
  redBlink:'\x1b[5;1;31m', // critical
  dim:     '\x1b[2m',      // subtle/secondary info
  bold:    '\x1b[1m',      // emphasis
  reset:   '\x1b[0m',      // reset
};

// ── Nerd Font glyphs (JetBrainsMono NF) ─────────────────────────────────────
const G = {
  branch:  '',   // git branch
  dir:     '',   // directory
  ctx:     '󰊠',   // context (brain)
  model:   '',   // model
  task:    '',   // task
  warn:    '',   // warning
  clock:   '',   // time
  skull:   '󰯈',   // critical
  shield:  '󰒃',   // protected branch
};

// ── Config ──────────────────────────────────────────────────────────────────
const CONTEXT_THRESHOLDS = { safe: 40, warn: 60, caution: 75, danger: 85 };
const AUTO_COMPACT_BUFFER_PCT = 16.5;
const PROTECTED_BRANCHES = ['main', 'master', 'production', 'release'];
const SESSION_TRACK_DIR = path.join(os.tmpdir(), 'claude-sessions');

// ── Helpers ─────────────────────────────────────────────────────────────────

function gitBranch(dir) {
  try {
    return execFileSync('git', ['rev-parse', '--abbrev-ref', 'HEAD'], {
      cwd: dir, stdio: ['pipe', 'pipe', 'pipe'], timeout: 500
    }).toString().trim();
  } catch { return null; }
}

function gitDirty(dir) {
  try {
    const out = execFileSync('git', ['status', '--porcelain', '-uno'], {
      cwd: dir, stdio: ['pipe', 'pipe', 'pipe'], timeout: 500
    }).toString().trim();
    return out.length > 0;
  } catch { return false; }
}

function trackSession(session) {
  if (!session) return null;
  try {
    if (!fs.existsSync(SESSION_TRACK_DIR)) fs.mkdirSync(SESSION_TRACK_DIR, { recursive: true });
    const file = path.join(SESSION_TRACK_DIR, `${session}.json`);
    let data;
    if (fs.existsSync(file)) {
      data = JSON.parse(fs.readFileSync(file, 'utf8'));
      data.ticks++;
    } else {
      data = { started: Date.now(), ticks: 1 };
    }
    fs.writeFileSync(file, JSON.stringify(data));
    return data;
  } catch { return null; }
}

function formatDuration(ms) {
  const mins = Math.floor(ms / 60000);
  if (mins < 60) return `${mins}m`;
  const hrs = Math.floor(mins / 60);
  const rem = mins % 60;
  return `${hrs}h${rem > 0 ? rem + 'm' : ''}`;
}

function contextBar(used, width = 10) {
  const filled = Math.round((used / 100) * width);
  let bar = '';
  for (let i = 0; i < width; i++) {
    if (i < filled) bar += '█';
    else if (i === filled) bar += '▒';
    else bar += '░';
  }
  return bar;
}

function contextColor(used) {
  if (used < CONTEXT_THRESHOLDS.safe) return C.green;
  if (used < CONTEXT_THRESHOLDS.warn) return C.cyan;
  if (used < CONTEXT_THRESHOLDS.caution) return C.yellow;
  if (used < CONTEXT_THRESHOLDS.danger) return C.orange;
  return C.redBlink;
}

// ── Main ────────────────────────────────────────────────────────────────────

let input = '';
const stdinTimeout = setTimeout(() => process.exit(0), 3000);
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  clearTimeout(stdinTimeout);
  try {
    const data = JSON.parse(input);
    const model = data.model?.display_name || 'Claude';
    const dir = data.workspace?.current_dir || process.cwd();
    const session = data.session_id || '';
    const remaining = data.context_window?.remaining_percentage;
    const homeDir = os.homedir();
    const claudeDir = process.env.CLAUDE_CONFIG_DIR || path.join(homeDir, '.claude');

    const segments = [];

    // ── GSD update notification ──
    const cacheFile = path.join(claudeDir, 'cache', 'gsd-update-check.json');
    if (fs.existsSync(cacheFile)) {
      try {
        const cache = JSON.parse(fs.readFileSync(cacheFile, 'utf8'));
        if (cache.update_available) {
          segments.push(`${C.yellow}${G.warn} gsd:update${C.reset}`);
        }
        if (cache.stale_hooks?.length > 0) {
          segments.push(`${C.red}${G.warn} stale hooks${C.reset}`);
        }
      } catch {}
    }

    // ── Model ──
    segments.push(`${C.dim}${G.model} ${model}${C.reset}`);

    // ── Current task ──
    const todosDir = path.join(claudeDir, 'todos');
    if (session && fs.existsSync(todosDir)) {
      try {
        const files = fs.readdirSync(todosDir)
          .filter(f => f.startsWith(session) && f.includes('-agent-') && f.endsWith('.json'))
          .map(f => ({ name: f, mtime: fs.statSync(path.join(todosDir, f)).mtime }))
          .sort((a, b) => b.mtime - a.mtime);
        if (files.length > 0) {
          const todos = JSON.parse(fs.readFileSync(path.join(todosDir, files[0].name), 'utf8'));
          const inProgress = todos.find(t => t.status === 'in_progress');
          if (inProgress?.activeForm) {
            const taskText = inProgress.activeForm.length > 30
              ? inProgress.activeForm.slice(0, 28) + '…'
              : inProgress.activeForm;
            segments.push(`${C.bold}${G.task} ${taskText}${C.reset}`);
          }
        }
      } catch {}
    }

    // ── Git branch awareness ──
    const branch = gitBranch(dir);
    if (branch) {
      const isProtected = PROTECTED_BRANCHES.includes(branch);
      const dirty = gitDirty(dir);
      if (isProtected) {
        segments.push(`${C.red}${G.shield} ${branch}${dirty ? ' !' : ''}${C.reset}`);
      } else {
        segments.push(`${C.cyan}${G.branch} ${branch}${dirty ? ` ${C.yellow}!${C.reset}` : ''}${C.reset}`);
      }
    }

    // ── Directory (Starship-style: truncated, bold blue) ──
    const dirParts = dir.split(path.sep);
    const truncated = dirParts.slice(-2).join('/');
    segments.push(`${C.blue}${G.dir} ${truncated}${C.reset}`);

    // ── Session duration (quota awareness) ──
    const sessionData = trackSession(session);
    if (sessionData) {
      const elapsed = Date.now() - sessionData.started;
      if (elapsed > 60000) {
        const dur = formatDuration(elapsed);
        const hrs = elapsed / 3600000;
        let durColor = C.dim;
        if (hrs >= 4) durColor = C.red;
        else if (hrs >= 3) durColor = C.orange;
        else if (hrs >= 2) durColor = C.yellow;
        segments.push(`${durColor}${G.clock} ${dur}${C.reset}`);
      }
    }

    // ── Context window intelligence ──
    if (remaining != null) {
      const usableRemaining = Math.max(0, ((remaining - AUTO_COMPACT_BUFFER_PCT) / (100 - AUTO_COMPACT_BUFFER_PCT)) * 100);
      const used = Math.max(0, Math.min(100, Math.round(100 - usableRemaining)));

      // Bridge file for context-monitor hook
      if (session) {
        try {
          const bridgePath = path.join(os.tmpdir(), `claude-ctx-${session}.json`);
          fs.writeFileSync(bridgePath, JSON.stringify({
            session_id: session,
            remaining_percentage: remaining,
            used_pct: used,
            timestamp: Math.floor(Date.now() / 1000)
          }));
        } catch {}
      }

      const bar = contextBar(used);
      const color = contextColor(used);
      const icon = used >= CONTEXT_THRESHOLDS.danger ? G.skull : G.ctx;
      segments.push(`${color}${icon} ${bar} ${used}%${C.reset}`);
    }

    // ── Render ──
    process.stdout.write(segments.join(` ${C.dim}│${C.reset} `));
  } catch {}
});
