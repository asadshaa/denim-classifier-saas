import React, { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import {
  Search, LayoutDashboard, Upload, BarChart3, BrainCircuit,
  Layers, Database, Scale, Settings, FlaskConical, X,
  Zap, Moon, Sun, LogOut
} from 'lucide-react';
import { useSettingsStore } from '../store/useSettingsStore';
import { useAuthStore } from '../store/authStore';

const COMMANDS = [
  { id: 'dashboard', label: 'Go to Dashboard', icon: LayoutDashboard, path: '/dashboard', group: 'Navigation' },
  { id: 'upload', label: 'Upload Image', icon: Upload, path: '/upload', group: 'Navigation' },
  { id: 'analytics', label: 'Open Analytics', icon: BarChart3, path: '/analytics', group: 'Navigation' },
  { id: 'model-insights', label: 'Model Intelligence', icon: BrainCircuit, path: '/model-insights', group: 'Navigation' },
  { id: 'active-learning', label: 'Active Learning', icon: Layers, path: '/active-learning', group: 'Navigation' },
  { id: 'dataset', label: 'Dataset Explorer', icon: Database, path: '/dataset', group: 'Navigation' },
  { id: 'compare', label: 'Class Comparison', icon: Scale, path: '/compare', group: 'Navigation' },
  { id: 'ab-testing', label: 'A/B Model Testing', icon: FlaskConical, path: '/ab-testing', group: 'Navigation' },
  { id: 'settings', label: 'Enterprise Settings', icon: Settings, path: '/settings', group: 'Navigation' },
  { id: 'toggle-dark', label: 'Toggle Dark Mode', icon: Moon, action: 'TOGGLE_DARK', group: 'Actions' },
  { id: 'logout', label: 'Logout', icon: LogOut, action: 'LOGOUT', group: 'Actions' },
];

const CommandPalette = ({ open, onClose }) => {
  const [query, setQuery] = useState('');
  const navigate = useNavigate();
  const inputRef = useRef();
  const { theme, setSettings } = useSettingsStore();
  const { logout } = useAuthStore();

  useEffect(() => {
    if (open) {
      setQuery('');
      setTimeout(() => inputRef.current?.focus(), 50);
    }
  }, [open]);

  const filtered = COMMANDS.filter(cmd =>
    cmd.label.toLowerCase().includes(query.toLowerCase())
  );

  const grouped = filtered.reduce((acc, cmd) => {
    if (!acc[cmd.group]) acc[cmd.group] = [];
    acc[cmd.group].push(cmd);
    return acc;
  }, {});

  const execute = (cmd) => {
    onClose();
    if (cmd.path) {
      navigate(cmd.path);
    } else if (cmd.action === 'TOGGLE_DARK') {
      setSettings({ theme: theme === 'dark' ? 'light' : 'dark' });
    } else if (cmd.action === 'LOGOUT') {
      logout();
      navigate('/login');
    }
  };

  return (
    <AnimatePresence>
      {open && (
        <>
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
            className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50"
            onClick={onClose}
          />

          {/* Palette */}
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: -20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: -20 }}
            transition={{ duration: 0.15 }}
            className="fixed top-[20%] left-1/2 -translate-x-1/2 w-full max-w-xl z-50"
          >
            <div className="bg-card border border-border rounded-3xl shadow-2xl overflow-hidden">
              {/* Search input */}
              <div className="flex items-center gap-3 px-5 py-4 border-b border-border">
                <Search className="w-5 h-5 text-muted-foreground shrink-0" />
                <input
                  ref={inputRef}
                  value={query}
                  onChange={(e) => setQuery(e.target.value)}
                  placeholder="Search commands..."
                  className="flex-1 bg-transparent text-foreground font-bold text-sm placeholder:text-muted-foreground/50 outline-none"
                  onKeyDown={(e) => {
                    if (e.key === 'Escape') onClose();
                    if (e.key === 'Enter' && filtered.length > 0) execute(filtered[0]);
                  }}
                />
                <button onClick={onClose} className="text-muted-foreground hover:text-foreground transition-colors">
                  <X className="w-4 h-4" />
                </button>
              </div>

              {/* Results */}
              <div className="max-h-80 overflow-y-auto py-2">
                {Object.keys(grouped).length === 0 ? (
                  <div className="px-5 py-10 text-center text-muted-foreground text-sm font-bold">
                    No commands found
                  </div>
                ) : (
                  Object.entries(grouped).map(([group, cmds]) => (
                    <div key={group} className="mb-2">
                      <p className="px-5 py-1.5 text-[10px] font-black text-muted-foreground uppercase tracking-widest">{group}</p>
                      {cmds.map(cmd => (
                        <button
                          key={cmd.id}
                          onClick={() => execute(cmd)}
                          className="w-full flex items-center gap-4 px-5 py-3 hover:bg-muted/50 transition-colors text-left"
                        >
                          <div className="w-8 h-8 rounded-xl bg-primary/10 flex items-center justify-center shrink-0">
                            <cmd.icon className="w-4 h-4 text-primary" />
                          </div>
                          <span className="text-sm font-bold text-foreground">{cmd.label}</span>
                          {cmd.path && (
                            <span className="ml-auto text-[10px] text-muted-foreground/50 font-bold truncate max-w-[100px]">{cmd.path}</span>
                          )}
                        </button>
                      ))}
                    </div>
                  ))
                )}
              </div>

              {/* Footer hint */}
              <div className="px-5 py-3 border-t border-border flex items-center gap-4 text-[10px] font-black text-muted-foreground/50 uppercase tracking-widest">
                <span>↑↓ Navigate</span>
                <span>↵ Select</span>
                <span>Esc Close</span>
                <span className="ml-auto">Ctrl+K to reopen</span>
              </div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
};

export default CommandPalette;
