# Troubleshooting

## MCP Server erscheint nicht in Claude Desktop nach Config-Edit

**Problem:** Der `fathom`-Eintrag in `claude_desktop_config.json` wird von der Claude Desktop App beim Speichern von Preferences (z.B. Sidebar-Wechsel) stillschweigend entfernt.

**Ursache:** Die Claude Desktop App liest die Config beim Start und schreibt sie bei jeder Preference-Aenderung komplett neu. Wenn die App beim Editieren der Config noch laeuft, ueberschreibt sie den manuellen Eintrag mit ihrem internen State — ohne den neuen Server.

**Loesung:**
1. Claude Desktop **komplett beenden** (Cmd+Q, nicht nur Fenster schliessen)
2. Config editieren: `~/Library/Application Support/Claude/claude_desktop_config.json`
3. Erst danach Claude Desktop wieder oeffnen

**Verifikation:**
```bash
python3 -c "import json; c=json.load(open('$HOME/Library/Application Support/Claude/claude_desktop_config.json')); print('fathom' in c['mcpServers'])"
```
Muss `True` ausgeben.
