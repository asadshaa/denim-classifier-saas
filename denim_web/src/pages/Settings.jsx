import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Cpu, 
  BrainCircuit, 
  TerminalSquare, 
  ShieldCheck, 
  FlaskConical,
  Zap,
  Server,
  Layers,
  Activity,
  Key,
  RefreshCw,
  Search,
  CheckCircle2,
  AlertTriangle,
  Download,
  Settings2,
  Lock
} from 'lucide-react';
import { useSettingsStore } from '../store/useSettingsStore';
import toast, { Toaster } from 'react-hot-toast';

// Reusable Custom Toggle Component
const CustomToggle = ({ enabled, onChange, label, description, highlight = false }) => (
  <div className={`flex items-center justify-between p-4 rounded-2xl border ${highlight ? 'bg-primary/5 border-primary/20' : 'bg-card border-border'} transition-colors`}>
    <div>
      <p className="text-foreground font-bold tracking-tight">{label}</p>
      {description && <p className="text-muted-foreground text-xs font-medium mt-1 leading-relaxed max-w-[280px]">{description}</p>}
    </div>
    <button 
      onClick={() => onChange(!enabled)}
      className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors duration-300 focus:outline-none ${enabled ? 'bg-primary' : 'bg-slate-300'}`}
    >
      <span className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform duration-300 ${enabled ? 'translate-x-6' : 'translate-x-1'}`} />
    </button>
  </div>
);

const Settings = () => {
  const [activeTab, setActiveTab] = useState('inference');
  
  // Global State
  const { 
    computeNode, predictionMode, confThreshold, activeLearning, 
    enableHeatmap, showTopK, batchProcessing, theme, setSettings 
  } = useSettingsStore();

  const handleSettingChange = (key, value) => {
    setSettings({ [key]: value });
    toast.success('Settings updated successfully', {
      style: {
        borderRadius: '16px',
        background: '#0F172A',
        color: '#fff',
        fontSize: '12px',
        fontWeight: 'bold',
      },
      iconTheme: {
        primary: '#215273',
        secondary: '#fff',
      },
    });
  };

  const tabs = [
    { id: 'inference', label: 'AI Inference Control', icon: <Cpu className="w-5 h-5" /> },
    { id: 'intelligence', label: 'Model Intelligence', icon: <BrainCircuit className="w-5 h-5" /> },
    { id: 'security', label: 'Audit & Security', icon: <ShieldCheck className="w-5 h-5" /> },
  ];

  return (
    <div className="max-w-7xl mx-auto font-manrope animate-in pb-20">
      <Toaster position="bottom-right" />
      <div className="mb-10">
        <div className="flex items-center gap-3 mb-2 text-primary">
           <Settings2 className="w-6 h-6" />
           <span className="font-black text-xs uppercase tracking-[0.3em]">System Configuration</span>
        </div>
        <h1 className="text-4xl md:text-5xl font-black text-foreground tracking-tighter">Enterprise Control Center</h1>
        <p className="text-muted-foreground mt-3 font-bold max-w-2xl">Manage MLOps lifecycle, inference hardware provisioning, and system security parameters.</p>
      </div>

      <div className="flex flex-col lg:flex-row gap-10">
        {/* Vertical Tabs Sidebar */}
        <div className="w-full lg:w-72 shrink-0 space-y-2">
          {tabs.map((tab) => {
            const isActive = activeTab === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`w-full flex items-center gap-4 px-5 py-4 rounded-2xl transition-all duration-300 font-bold text-sm tracking-tight relative ${
                  isActive 
                    ? 'bg-primary text-white shadow-lg shadow-primary/20' 
                    : 'text-muted-foreground hover:bg-card hover:text-primary'
                }`}
              >
                {tab.icon}
                {tab.label}
                {isActive && (
                  <motion.div layoutId="activeTabIndicator" className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-8 bg-background rounded-r-full" />
                )}
              </button>
            );
          })}
        </div>

        {/* Content Area */}
        <div className="flex-1 min-w-0">
          <AnimatePresence mode="wait">
            <motion.div
              key={activeTab}
              initial={{ opacity: 0, x: 10 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -10 }}
              transition={{ duration: 0.2 }}
              className="space-y-8"
            >
              
              {/* TAB 1: INFERENCE CONTROL */}
              {activeTab === 'inference' && (
                <>
                  <div className="glass-card rounded-[2.5rem] p-8 border-border">
                    <div className="flex items-center gap-3 mb-6 border-b border-border pb-4">
                       <Search className="w-6 h-6 text-primary" />
                       <h2 className="text-2xl font-black text-foreground tracking-tight">Prediction Strategy</h2>
                    </div>
                    
                     <div className="space-y-8">
                       <CustomToggle 
                         enabled={showTopK} onChange={(v) => handleSettingChange('showTopK', v)}
                         label="Top-K Output Display"
                         description="Display the top 3 potential classifications instead of just the absolute highest probability."
                       />
                       
                       <CustomToggle 
                         enabled={batchProcessing} onChange={(v) => handleSettingChange('batchProcessing', v)}
                         label="Parallel Batch Processing"
                         description="Process up to 100 images concurrently using multi-threaded web workers."
                       />
                       
                       <CustomToggle 
                         enabled={theme === 'dark'} 
                         onChange={(v) => handleSettingChange('theme', v ? 'dark' : 'light')}
                         label="Dark Mode (High Contrast)"
                         description="Switch to a deep slate navy theme optimized for low-light environments."
                         highlight={theme === 'dark'}
                       />
                     </div>
                  </div>
                </>
              )}

              {/* TAB 2: MODEL INTELLIGENCE */}
              {activeTab === 'intelligence' && (
                <>
                  <div className="glass-card rounded-[2.5rem] p-8 border-border bg-gradient-to-br from-indigo-50 to-transparent">
                    <div className="flex items-center gap-3 mb-6 border-b border-border pb-4">
                       <RefreshCw className="w-6 h-6 text-indigo-500" />
                       <h2 className="text-2xl font-black text-foreground tracking-tight">Active Learning Pipeline</h2>
                    </div>
                    
                    <CustomToggle 
                      enabled={activeLearning} onChange={(v) => handleSettingChange('activeLearning', v)}
                      label="Continuous Learning (Auto-Routing)"
                      description="Automatically send low-confidence predictions to the dataset curation pool for the next training cycle."
                      highlight={true}
                    />

                    <div className="mt-6 flex items-center justify-between p-6 bg-background rounded-2xl border border-border shadow-sm">
                       <div>
                          <h4 className="font-black text-foreground text-lg">Retraining Queue</h4>
                          <p className="text-xs text-muted-foreground font-bold mt-1">Samples collected for Next-Gen Model V2</p>
                       </div>
                       <div className="text-right">
                          <span className="text-4xl font-black text-indigo-600 tracking-tighter">142</span>
                          <span className="block text-[10px] font-black uppercase text-muted-foreground/70 tracking-widest mt-1">Images</span>
                       </div>
                    </div>
                  </div>

                  <div className="glass-card rounded-[2.5rem] p-8 border-border">
                    <div className="flex items-center gap-3 mb-6 border-b border-border pb-4">
                       <Layers className="w-6 h-6 text-primary" />
                       <h2 className="text-2xl font-black text-foreground tracking-tight">Explainability (XAI)</h2>
                    </div>
                    <div className="space-y-4">
                       <CustomToggle 
                         enabled={enableHeatmap} onChange={(v) => handleSettingChange('enableHeatmap', v)}
                         label="Grad-CAM Visual Attention Heatmaps"
                         description="Generate neural network attention overlays to explain the model's decision-making logic."
                       />
                       
                       <div className={`p-4 rounded-xl border transition-opacity ${enableHeatmap ? 'opacity-100 border-border bg-card' : 'opacity-50 border-border pointer-events-none'}`}>
                          <label className="block text-sm font-bold text-foreground mb-2">Display Mode</label>
                          <div className="flex gap-4">
                             <label className="flex items-center gap-2 cursor-pointer">
                               <input type="radio" name="heatmap_mode" className="accent-primary w-4 h-4" defaultChecked />
                               <span className="text-sm font-medium text-muted-foreground">Overlay on Image</span>
                             </label>
                             <label className="flex items-center gap-2 cursor-pointer">
                               <input type="radio" name="heatmap_mode" className="accent-primary w-4 h-4" />
                               <span className="text-sm font-medium text-muted-foreground">Side-by-side</span>
                             </label>
                          </div>
                       </div>
                    </div>
                  </div>
                </>
              )}

              {/* TAB 4: SECURITY */}
              {activeTab === 'security' && (
                <div className="glass-card rounded-[2.5rem] p-8 border-border overflow-hidden">
                  <div className="flex items-center justify-between mb-8 border-b border-border pb-4">
                     <div className="flex items-center gap-3">
                        <Lock className="w-6 h-6 text-foreground" />
                        <h2 className="text-2xl font-black text-foreground tracking-tight">System Activity Logs</h2>
                     </div>
                     <button className="flex items-center gap-2 text-xs font-black uppercase tracking-widest text-primary hover:text-primary/80 transition-colors">
                        <Download className="w-4 h-4" /> Export CSV
                     </button>
                  </div>
                  
                  <div className="overflow-x-auto">
                     <table className="w-full text-left border-collapse">
                        <thead>
                           <tr className="border-b border-border">
                              <th className="pb-3 text-xs font-black text-muted-foreground uppercase tracking-widest">Timestamp</th>
                              <th className="pb-3 text-xs font-black text-muted-foreground uppercase tracking-widest">Event</th>
                              <th className="pb-3 text-xs font-black text-muted-foreground uppercase tracking-widest">IP Address</th>
                              <th className="pb-3 text-xs font-black text-muted-foreground uppercase tracking-widest">Status</th>
                           </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-100">
                           {[
                             { t: '10 mins ago', e: 'Batch Inference (50 files)', ip: '192.168.1.4', s: 'Success', c: 'text-emerald-500 bg-emerald-50' },
                             { t: '2 hours ago', e: 'Compute Node Changed -> T4', ip: '192.168.1.4', s: 'Config Updated', c: 'text-indigo-500 bg-indigo-50' },
                             { t: '5 hours ago', e: 'REST API Key Accessed', ip: '192.168.1.4', s: 'Security Alert', c: 'text-amber-500 bg-amber-50' },
                             { t: '1 day ago', e: 'Invalid Login Attempt', ip: '104.28.19.1', s: 'Failed', c: 'text-red-500 bg-red-50' },
                             { t: '2 days ago', e: 'Dataset Export Downloaded', ip: '192.168.1.4', s: 'Success', c: 'text-emerald-500 bg-emerald-50' },
                           ].map((log, i) => (
                             <tr key={i} className="hover:bg-muted/30/50 transition-colors">
                                <td className="py-4 text-sm font-bold text-muted-foreground">{log.t}</td>
                                <td className="py-4 text-sm font-bold text-foreground">{log.e}</td>
                                <td className="py-4 text-sm font-mono text-muted-foreground">{log.ip}</td>
                                <td className="py-4">
                                   <span className={`text-[10px] font-black uppercase tracking-widest px-2 py-1 rounded-md ${log.c}`}>{log.s}</span>
                                </td>
                             </tr>
                           ))}
                        </tbody>
                     </table>
                  </div>
                </div>
              )}

            </motion.div>
          </AnimatePresence>
        </div>
      </div>
    </div>
  );
};

export default Settings;
