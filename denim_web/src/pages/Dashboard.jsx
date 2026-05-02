import React, { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../store/authStore';
import { 
  Upload as UploadIcon, 
  Activity, 
  Database, 
  Clock, 
  TrendingUp, 
  ArrowUpRight, 
  ArrowDownRight,
  Plus,
  Zap
} from 'lucide-react';
import axios from 'axios';
import API_URL from '../api';
import { useScanStore } from '../store/scanStore';

const Dashboard = () => {
  const navigate = useNavigate();
  const { user } = useAuthStore();
  const { setCurrentScan, scanHistory } = useScanStore();
  const [stats, setStats] = useState({
    totalScans: 0,
    avgConfidence: 0,
    activeAnomalies: 0,
    growth: 12.5
  });

  // Take latest 5 from history
  const recentScans = scanHistory.slice(0, 5);

  useEffect(() => {
    // Calculate stats purely from client-side history
    const total = scanHistory.length;
    const avg = total > 0 ? (scanHistory.reduce((acc, curr) => acc + curr.confidence_main, 0) / total) * 100 : 0;
    const anomalies = scanHistory.filter(s => s.confidence_main < 0.85).length;
    
    setStats({
      totalScans: total,
      avgConfidence: avg.toFixed(1),
      activeAnomalies: anomalies,
      growth: 12.5
    });
  }, [scanHistory]);

  const metricCards = [
    { 
      title: 'Total Scans', 
      value: stats.totalScans, 
      trend: '+14%', 
      isPositive: true, 
      icon: <Database className="w-5 h-5 text-primary" />,
      color: 'primary'
    },
    { 
      title: 'Avg Confidence', 
      value: `${stats.avgConfidence}%`, 
      trend: '+2.1%', 
      isPositive: true, 
      icon: <TrendingUp className="w-5 h-5 text-secondary" />,
      color: 'secondary'
    },
    { 
      title: 'Low Conf Anomalies', 
      value: stats.activeAnomalies, 
      trend: '-5%', 
      isPositive: true, 
      icon: <Activity className="w-5 h-5 text-orange-400" />,
      color: 'orange'
    },
    { 
      title: 'System Uptime', 
      value: '99.9%', 
      trend: 'Stable', 
      isPositive: true, 
      icon: <Zap className="w-5 h-5 text-emerald-400" />,
      color: 'emerald'
    }
  ];

  const colorMap = {
    primary: 'bg-primary/10 text-primary',
    secondary: 'bg-secondary/10 text-secondary',
    orange: 'bg-orange-400/10 text-orange-400',
    emerald: 'bg-emerald-400/10 text-emerald-400'
  };

  return (
    <div className="space-y-12 animate-in relative">
      {/* Welcome Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h1 className="text-5xl font-black text-foreground tracking-tighter">Overview</h1>
          <p className="text-muted-foreground mt-2 font-bold tracking-tight">Managing {stats.totalScans} industrial fabric signatures.</p>
        </div>
        <button 
          onClick={() => navigate('/upload')}
          className="primary-button group shadow-primary/20"
        >
          <Plus className="w-4 h-4 group-hover:rotate-90 transition-transform" />
          New Research Scan
        </button>
      </div>

      {/* Metric Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {metricCards.map((metric, idx) => (
          <motion.div
            key={idx}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: idx * 0.1 }}
            className="glass-card p-8 rounded-[2.5rem] hover:border-white/10 transition-all group"
          >
            <div className="flex justify-between items-start mb-6">
              <div className={`p-4 rounded-2xl ${colorMap[metric.color]}`}>
                {metric.icon}
              </div>
              <div className={`flex items-center gap-1 text-[10px] font-black uppercase tracking-widest ${metric.isPositive ? 'text-emerald-400' : 'text-red-400'}`}>
                {metric.isPositive ? <ArrowUpRight className="w-3 h-3" /> : <ArrowDownRight className="w-3 h-3" />}
                {metric.trend}
              </div>
            </div>
            <h3 className="text-muted-foreground text-xs font-black uppercase tracking-widest mb-1">{metric.title}</h3>
            <p className="text-3xl font-black text-foreground mt-1 group-hover:scale-105 transition-transform origin-left tracking-tighter">{metric.value}</p>
          </motion.div>
        ))}
      </div>

      {/* Recent Activity Table */}
      <div className="grid lg:grid-cols-3 gap-10">
        <div className="lg:col-span-2 glass-card rounded-[3rem] overflow-hidden flex flex-col border-white/[0.03]">
          <div className="p-10 border-b border-white/5 flex items-center justify-between bg-background/[0.01]">
            <div>
              <h3 className="text-2xl font-black text-foreground tracking-tighter">Recent Scans</h3>
              <p className="text-muted-foreground text-sm font-bold tracking-tight">Last 5 active neural inferences</p>
            </div>
            <button 
              onClick={() => navigate('/analytics')}
              className="text-[10px] font-black text-primary hover:text-foreground uppercase tracking-[0.2em] transition-colors"
            >
              View Analytics
            </button>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="text-muted-foreground text-[10px] uppercase tracking-[0.25em] font-black">
                  <th className="px-10 py-6">Fabric Signature</th>
                  <th className="px-10 py-6">Variant</th>
                  <th className="px-10 py-6">Certainty</th>
                  <th className="px-10 py-6">Date</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-white/5">
                {recentScans.map((scan) => (
                  <tr 
                    key={scan.id || scan._id || Math.random()} 
                    onClick={() => {
                      setCurrentScan(scan);
                      navigate('/result');
                    }}
                    className="group hover:bg-background/[0.02] transition-all cursor-pointer"
                  >
                    <td className="px-10 py-6">
                      <div className="flex items-center gap-4">
                        <div className="w-12 h-12 rounded-xl bg-background/5 border border-white/10 overflow-hidden group-hover:scale-110 transition-transform shadow-2xl flex items-center justify-center">
                           {/* For client-side, we might not have a URL without base64 or server static files, so use an icon fallback if needed, but if the backend returns a local url, we use it */}
                           {scan.imageUrl ? (
                             <img src={`${API_URL}${scan.imageUrl}`} className="w-full h-full object-cover" alt="Fabric" />
                           ) : (
                             <Database className="w-6 h-6 text-muted-foreground/70" />
                           )}
                        </div>
                        <span className="text-sm font-black text-foreground group-hover:text-primary transition-colors tracking-tight">{scan.class}</span>
                      </div>
                    </td>
                    <td className="px-10 py-6">
                      <span className="text-sm font-bold text-muted-foreground">{scan.subclass !== undefined && scan.subclass !== null ? `V${scan.subclass}` : 'N/A'}</span>
                    </td>
                    <td className="px-10 py-6">
                      <div className="flex items-center gap-2">
                        <div className="flex-1 h-2 bg-muted/50 rounded-full overflow-hidden w-24">
                           <div className="h-full bg-primary" style={{ width: `${scan.confidence_main * 100}%` }} />
                        </div>
                        <span className="text-sm font-black text-foreground">{(scan.confidence_main * 100).toFixed(1)}%</span>
                      </div>
                    </td>
                    <td className="px-10 py-6 text-sm font-bold text-muted-foreground">
                      {scan.timestamp ? new Date(scan.timestamp).toLocaleString() : 'Just now'}
                    </td>
                  </tr>
                ))}
                {recentScans.length === 0 && (
                  <tr>
                    <td colSpan="4" className="px-10 py-12 text-center text-muted-foreground font-bold">
                      No scans performed yet. Upload an image to populate history.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>

        {/* Small Analytics Preview */}
        <div className="glass-card rounded-[3rem] p-10 flex flex-col justify-between border-white/[0.03]">
           <div>
              <h3 className="text-2xl font-black text-foreground mb-2 tracking-tighter">Model Pulse</h3>
              <p className="text-muted-foreground text-sm font-bold mb-12 tracking-tight">Real-time inference stability.</p>
              
              <div className="space-y-10">
                {[
                  { label: 'CNN Extraction', val: '12ms', status: 'Optimal', color: 'primary' },
                  { label: 'Multi-Head Logic', val: '28ms', status: 'Optimal', color: 'secondary' },
                  { label: 'Database I/O', val: '5ms', status: 'Optimal', color: 'emerald' }
                ].map((item, i) => (
                  <div key={i} className="flex justify-between items-center">
                    <div>
                      <p className="text-[10px] font-black text-muted-foreground uppercase tracking-[0.2em]">{item.label}</p>
                      <p className="text-xl font-black text-foreground mt-1 tracking-tighter">{item.val}</p>
                    </div>
                    <span className="px-3 py-1.5 rounded-xl bg-background/5 text-primary text-[10px] font-black uppercase tracking-widest border border-white/5 shadow-inner">
                      {item.status}
                    </span>
                  </div>
                ))}
              </div>
           </div>
           
           <div className="mt-12 p-6 rounded-3xl bg-primary/5 border border-primary/10">
              <div className="flex items-center gap-3 mb-3">
                 <div className="w-2 h-2 rounded-full bg-primary animate-pulse shadow-[0_0_10px_rgba(128,203,196,1)]" />
                 <span className="text-[10px] font-black text-primary uppercase tracking-[0.25em]">Core Online</span>
              </div>
              <p className="text-[11px] font-bold text-muted-foreground leading-relaxed">EfficientNet-B0 v2.4.0 is active with CUDA hardware acceleration.</p>
           </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
