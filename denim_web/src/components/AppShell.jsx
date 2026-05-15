import React, { useState, useEffect, useCallback } from 'react';
import { Outlet, Link, useLocation, useNavigate } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  LayoutDashboard, Upload, BarChart3, BrainCircuit, LogOut, Settings, Layers,
  Scale, ChevronLeft, ChevronRight, User, Bell, Database, FlaskConical,
  Search, Zap, CheckCircle2, AlertTriangle, PackageOpen
} from 'lucide-react';
import { useAuthStore } from '../store/authStore';
import { useScanStore } from '../store/scanStore';
import InteractiveDots from './InteractiveDots';
import CommandPalette from './CommandPalette';
import axios from 'axios';

const ACTION_ICONS = {
  SINGLE_SCAN: { icon: Zap, color: 'text-primary bg-primary/10' },
  BATCH_SCAN: { icon: PackageOpen, color: 'text-secondary bg-secondary/10' },
  FEEDBACK_SUBMITTED: { icon: CheckCircle2, color: 'text-emerald-500 bg-emerald-500/10' },
  LOW_CONFIDENCE_DETECTED: { icon: AlertTriangle, color: 'text-amber-500 bg-amber-500/10' },
  LOGIN: { icon: User, color: 'text-blue-500 bg-blue-500/10' },
  DEFAULT: { icon: Zap, color: 'text-muted-foreground bg-muted' },
};

const AppShell = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const { user, logout } = useAuthStore();
  const [isCollapsed, setIsCollapsed] = useState(false);
  const [paletteOpen, setPaletteOpen] = useState(false);
  const [activityLogs, setActivityLogs] = useState([]);
  const [showActivity, setShowActivity] = useState(false);

  const navItems = [
    { name: 'Dashboard', path: '/dashboard', icon: <LayoutDashboard className="w-5 h-5" /> },
    { name: 'New Scan', path: '/upload', icon: <Upload className="w-5 h-5" /> },
    { name: 'Analytics', path: '/analytics', icon: <BarChart3 className="w-5 h-5" /> },
    { name: 'Model Insights', path: '/model-insights', icon: <BrainCircuit className="w-5 h-5" /> },
    { name: 'Active Learning', path: '/active-learning', icon: <Layers className="w-5 h-5" /> },
    { name: 'Dataset Explorer', path: '/dataset', icon: <Database className="w-5 h-5" /> },
    { name: 'Class Compare', path: '/compare', icon: <Scale className="w-5 h-5" /> },
    { name: 'A/B Testing', path: '/ab-testing', icon: <FlaskConical className="w-5 h-5" /> },
  ];

  // Ctrl+K to open command palette
  useEffect(() => {
    const handler = (e) => {
      if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
        e.preventDefault();
        setPaletteOpen(true);
      }
    };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, []);

  // Poll live activity feed every 15 seconds
  const fetchActivity = useCallback(async () => {
    try {
      const config = { headers: { Authorization: `Bearer ${localStorage.getItem('token')}` } };
      const res = await axios.get('http://localhost:5000/api/activity?limit=10', config);
      setActivityLogs(res.data);
    } catch (err) {
      // Silent fail — don't disrupt UI
    }
  }, []);

  useEffect(() => {
    fetchActivity();
    const interval = setInterval(fetchActivity, 15000);
    return () => clearInterval(interval);
  }, [fetchActivity]);

  const { clearHistory } = useScanStore();

  const handleLogout = () => {
    clearHistory(); // Wipe local scan cache
    logout();
    navigate('/login');
  };

  const timeAgo = (date) => {
    const seconds = Math.floor((new Date() - new Date(date)) / 1000);
    if (seconds < 60) return `${seconds}s ago`;
    if (seconds < 3600) return `${Math.floor(seconds / 60)}m ago`;
    return `${Math.floor(seconds / 3600)}h ago`;
  };

  return (
    <div className="flex min-h-screen bg-background font-manrope selection:bg-primary/30 relative">
      <InteractiveDots />
      <CommandPalette open={paletteOpen} onClose={() => setPaletteOpen(false)} />
      
      {/* Sidebar */}
      <motion.aside 
        initial={false}
        animate={{ width: isCollapsed ? 80 : 280 }}
        className="fixed left-0 top-0 h-full bg-card/90 backdrop-blur-2xl border-r border-border z-50 flex flex-col"
      >
        <div className="p-6 flex items-center justify-between">
          <div className={`flex items-center gap-3 overflow-hidden ${isCollapsed ? 'hidden' : 'flex'}`}>
            <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center overflow-hidden border border-border">
              <img src="/logo.png" alt="US Denim Logo" className="w-full h-full object-contain p-1" />
            </div>
            <span className="font-black text-foreground tracking-tighter text-lg">DenimAI</span>
          </div>
          <button 
            onClick={() => setIsCollapsed(!isCollapsed)}
            className="w-8 h-8 rounded-lg hover:bg-muted flex items-center justify-center text-muted-foreground hover:text-primary transition-colors ml-auto"
          >
            {isCollapsed ? <ChevronRight className="w-4 h-4" /> : <ChevronLeft className="w-4 h-4" />}
          </button>
        </div>

        <nav className="flex-1 px-4 py-6 space-y-1 overflow-y-auto">
          {navItems.map((item) => {
            const isActive = location.pathname === item.path;
            return (
              <Link
                key={item.path}
                to={item.path}
                className={`nav-item ${isActive ? 'nav-item-active' : ''} ${isCollapsed ? 'justify-center px-0' : ''}`}
                title={isCollapsed ? item.name : ''}
              >
                <div className="shrink-0">{item.icon}</div>
                {!isCollapsed && <span className="font-bold text-sm tracking-tight">{item.name}</span>}
                {isActive && !isCollapsed && (
                  <motion.div layoutId="activeNav" className="ml-auto w-1.5 h-1.5 rounded-full bg-primary" />
                )}
              </Link>
            );
          })}
        </nav>

        <div className="p-4 border-t border-border space-y-1">
          <Link to="/settings" className={`nav-item w-full ${location.pathname === '/settings' ? 'nav-item-active' : ''} ${isCollapsed ? 'justify-center px-0' : ''}`}>
            <Settings className="w-5 h-5 shrink-0" />
            {!isCollapsed && <span className="font-bold text-sm tracking-tight">Control Center</span>}
          </Link>
          <button 
            onClick={handleLogout}
            className={`nav-item w-full text-red-500 hover:text-red-600 hover:bg-red-50 dark:hover:bg-red-500/10 ${isCollapsed ? 'justify-center px-0' : ''}`}
          >
            <LogOut className="w-5 h-5 shrink-0" />
            {!isCollapsed && <span className="font-bold text-sm tracking-tight">Logout</span>}
          </button>
        </div>
      </motion.aside>

      {/* Main Content Area */}
      <main 
        className="flex-1 transition-all duration-300 min-h-screen relative"
        style={{ marginLeft: isCollapsed ? 80 : 280 }}
      >
        {/* Top Header */}
        <header className="h-16 border-b border-border flex items-center justify-between px-8 bg-card/80 backdrop-blur-md sticky top-0 z-40">
          <div className="flex items-center gap-2 text-sm font-bold tracking-tight">
             <span className="text-muted-foreground">Workspace</span>
             <span className="text-muted-foreground/50">/</span>
             <span className="text-primary capitalize">
               {location.pathname.split('/').pop()?.replace(/-/g, ' ') || 'Overview'}
             </span>
          </div>
          
          <div className="flex items-center gap-4">
            {/* Ctrl+K command palette trigger */}
            <button
              onClick={() => setPaletteOpen(true)}
              className="hidden md:flex items-center gap-2 px-3 py-1.5 rounded-lg bg-muted/50 border border-border text-muted-foreground text-xs font-bold hover:border-primary/50 hover:text-primary transition-all"
            >
              <Search className="w-3.5 h-3.5" />
              <span>Search...</span>
              <span className="ml-2 px-1.5 py-0.5 rounded bg-muted text-[10px] font-black">⌘K</span>
            </button>

            {/* Live Activity Bell */}
            <div className="relative">
              <button
                onClick={() => setShowActivity(!showActivity)}
                className="relative p-2 text-muted-foreground hover:text-primary transition-colors"
              >
                <Bell className="w-5 h-5" />
                {activityLogs.length > 0 && (
                  <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-primary rounded-full border-2 border-background" />
                )}
              </button>

              {/* Activity Dropdown */}
              <AnimatePresence>
                {showActivity && (
                  <>
                    <div className="fixed inset-0 z-40" onClick={() => setShowActivity(false)} />
                    <motion.div
                      initial={{ opacity: 0, y: 10, scale: 0.95 }}
                      animate={{ opacity: 1, y: 0, scale: 1 }}
                      exit={{ opacity: 0, y: 10, scale: 0.95 }}
                      className="absolute right-0 top-12 w-80 bg-card border border-border rounded-2xl shadow-2xl z-50 overflow-hidden"
                    >
                      <div className="p-4 border-b border-border flex items-center justify-between">
                        <h3 className="text-sm font-black text-foreground">Live Activity Feed</h3>
                        <span className="text-[10px] font-black text-primary bg-primary/10 px-2 py-0.5 rounded-full">LIVE</span>
                      </div>
                      <div className="max-h-72 overflow-y-auto">
                        {activityLogs.length === 0 ? (
                          <div className="p-6 text-center text-muted-foreground text-xs font-bold">
                            No activity yet. Upload an image to start!
                          </div>
                        ) : activityLogs.map((log) => {
                          const cfg = ACTION_ICONS[log.action] || ACTION_ICONS.DEFAULT;
                          return (
                            <div key={log._id} className="flex items-start gap-3 p-3 hover:bg-muted/30 transition-colors border-b border-border/50 last:border-0">
                              <div className={`w-7 h-7 rounded-lg flex items-center justify-center shrink-0 mt-0.5 ${cfg.color}`}>
                                <cfg.icon className="w-3.5 h-3.5" />
                              </div>
                              <div className="flex-1 min-w-0">
                                <p className="text-xs font-bold text-foreground leading-tight truncate">{log.detail}</p>
                                <p className="text-[10px] text-muted-foreground font-bold mt-0.5">{timeAgo(log.timestamp)}</p>
                              </div>
                            </div>
                          );
                        })}
                      </div>
                      <div className="p-3 border-t border-border text-center">
                        <span className="text-[10px] font-black text-muted-foreground uppercase tracking-widest">Refreshes every 15s</span>
                      </div>
                    </motion.div>
                  </>
                )}
              </AnimatePresence>
            </div>

            <div className="flex items-center gap-3 pl-4 border-l border-border">
              <div className="text-right hidden sm:block">
                <p className="text-xs font-black text-foreground leading-none mb-1">{user?.name || 'Researcher'}</p>
                <p className="text-[10px] font-bold text-muted-foreground uppercase tracking-widest">Enterprise Access</p>
              </div>
              <div className="w-9 h-9 rounded-full bg-muted flex items-center justify-center text-primary border border-border shadow-sm overflow-hidden">
                <User className="w-5 h-5" />
              </div>
            </div>
          </div>
        </header>

        {/* Page Content with Framer Motion Transition */}
        <div className="p-8 pb-20">
          <AnimatePresence mode="wait">
            <motion.div
              key={location.pathname}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              transition={{ duration: 0.25, ease: [0.23, 1, 0.32, 1] }}
            >
              <Outlet />
            </motion.div>
          </AnimatePresence>
        </div>

        {/* Dynamic Gradient Overlay */}
        <div className="fixed bottom-0 right-0 w-[600px] h-[600px] bg-primary/5 blur-[120px] pointer-events-none -z-10" />
      </main>
    </div>
  );
};

export default AppShell;
