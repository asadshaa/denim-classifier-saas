import React, { useEffect, useState, useMemo } from 'react';
import { motion } from 'framer-motion';
import { 
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, 
  AreaChart, Area, LineChart, Line, PieChart, Pie, Cell,
  Radar, RadarChart, PolarGrid, PolarAngleAxis, PolarRadiusAxis
} from 'recharts';
import { 
  Download, 
  Filter, 
  Calendar, 
  ChevronDown, 
  TrendingUp, 
  Activity, 
  Layers,
  ArrowUpRight,
  Target,
  Zap,
  Cpu,
  PieChart as PieChartIcon
} from 'lucide-react';
import { useScanStore } from '../store/scanStore';

const COLORS = ['#80CBC4', '#B39DDB', '#FFAB91', '#81C784', '#FFF176', '#4DB6AC'];

const Analytics = () => {
  const [loading, setLoading] = useState(true);
  const [data, setData] = useState({
    usageStats: [],
    classDistribution: [],
    confidenceTrend: [],
    topClasses: []
  });

  const { scanHistory } = useScanStore();

  useEffect(() => {
    // Generate analytics dynamically from scanHistory
    
    // Class Distribution
    const classCount = scanHistory.reduce((acc, scan) => {
      acc[scan.class] = (acc[scan.class] || 0) + 1;
      return acc;
    }, {});
    const dist = Object.entries(classCount)
      .map(([name, value]) => ({ name, value }))
      .sort((a, b) => b.value - a.value);

    // Confidence Trend (chronological)
    const trend = [...scanHistory].reverse().map((scan, i) => ({
      date: `S${i+1}`,
      conf: scan.confidence_main * 100
    }));

    // Group by Day (or hour for demo purposes)
    const dateCount = scanHistory.reduce((acc, scan) => {
      const d = new Date(scan.timestamp || Date.now()).toLocaleDateString();
      acc[d] = (acc[d] || 0) + 1;
      return acc;
    }, {});
    
    const usage = Object.entries(dateCount).map(([date, count]) => ({ date, count }));

    setData({
      usageStats: usage.length > 0 ? usage : [{ date: 'Today', count: 0 }],
      classDistribution: dist,
      confidenceTrend: trend,
      topClasses: dist.slice(0, 5)
    });
    setLoading(false);
  }, [scanHistory]);

  const handleExport = () => {
    const headers = ['Date', 'Inference Count'];
    const rows = [headers.join(',')];
    data.usageStats.forEach(r => rows.push(`${r.date},${r.count}`));
    
    const csvContent = "\uFEFF" + rows.join('\n');
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = window.URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.setAttribute("href", url);
    link.setAttribute("download", "analytics_report.csv");
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    window.URL.revokeObjectURL(url);
  };

  return (
    <div className="space-y-12 pb-20 animate-in font-manrope">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div>
          <h1 className="text-5xl font-black text-foreground tracking-tighter">Intelligence</h1>
          <p className="text-muted-foreground mt-2 font-bold tracking-tight">Advanced model auditing and throughput metrics.</p>
        </div>
        <div className="flex gap-4">
          <button className="secondary-button !px-6 border-white/[0.03]">
             <Calendar className="w-4 h-4 text-primary" />
             Last 30 Days
             <ChevronDown className="w-4 h-4 text-muted-foreground" />
          </button>
          <button onClick={handleExport} className="primary-button !px-8">
             <Download className="w-4 h-4" />
             Export Audit
          </button>
        </div>
      </div>

      {/* Hero Stats (Mobile Style Bento Cards) */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
         <div className="glass-card p-10 rounded-[3rem] bg-gradient-to-br from-primary/5 to-transparent border-primary/10">
            <div className="flex justify-between items-start mb-10">
               <div className="p-4 rounded-2xl bg-primary/10 text-primary shadow-xl shadow-primary/5">
                  <Activity className="w-8 h-8" />
               </div>
               <div className="flex items-center gap-1 text-[10px] font-black text-emerald-400 bg-emerald-400/10 px-3 py-1 rounded-full border border-emerald-400/20">
                  <ArrowUpRight className="w-3 h-3" /> 12%
               </div>
            </div>
            <h3 className="text-muted-foreground text-xs font-black uppercase tracking-[0.2em]">Global Throughput</h3>
            <p className="text-6xl font-black text-foreground mt-2 tracking-tighter">1.2M <span className="text-xl text-foreground font-bold tracking-tight">/mo</span></p>
         </div>

         <div className="glass-card p-10 rounded-[3rem] bg-gradient-to-br from-secondary/5 to-transparent border-secondary/10">
            <div className="flex justify-between items-start mb-10">
               <div className="p-4 rounded-2xl bg-secondary/10 text-secondary shadow-xl shadow-secondary/5">
                  <Target className="w-8 h-8" />
               </div>
               <div className="flex items-center gap-1 text-[10px] font-black text-emerald-400 bg-emerald-400/10 px-3 py-1 rounded-full border border-emerald-400/20">
                  <ArrowUpRight className="w-3 h-3" /> 0.8%
               </div>
            </div>
            <h3 className="text-muted-foreground text-xs font-black uppercase tracking-[0.2em]">Model Accuracy</h3>
            <p className="text-6xl font-black text-foreground mt-2 tracking-tighter">98.4 <span className="text-xl text-foreground font-bold tracking-tight">%</span></p>
         </div>

         <div className="glass-card p-10 rounded-[3rem] bg-gradient-to-br from-primary/5 to-transparent border-primary/10">
            <div className="flex justify-between items-start mb-10">
               <div className="p-4 rounded-2xl bg-primary/10 text-primary shadow-xl shadow-primary/5">
                  <Cpu className="w-8 h-8" />
               </div>
               <div className="flex items-center gap-1 text-[10px] font-black text-muted-foreground bg-background/5 px-3 py-1 rounded-full border border-white/5">
                  Stable
               </div>
            </div>
            <h3 className="text-muted-foreground text-xs font-black uppercase tracking-[0.2em]">Active Kernels</h3>
            <p className="text-6xl font-black text-foreground mt-2 tracking-tighter">26 <span className="text-xl text-foreground font-bold tracking-tight">Heads</span></p>
         </div>
      </div>

      {/* Charts Grid */}
      <div className="grid lg:grid-cols-2 gap-10">
        <div className="glass-card p-10 rounded-[3rem] border-white/[0.03]">
           <div className="flex items-center justify-between mb-12">
              <div className="flex items-center gap-4">
                 <TrendingUp className="w-6 h-6 text-primary" />
                 <h3 className="text-2xl font-black text-foreground tracking-tighter">Usage Pulse</h3>
              </div>
              <div className="flex items-center gap-3 px-4 py-2 rounded-full bg-background/5 border border-white/5 text-[10px] font-black text-muted-foreground uppercase tracking-widest">
                 <span className="w-2 h-2 rounded-full bg-primary shadow-[0_0_8px_rgba(128,203,196,1)]" /> Inferences
              </div>
           </div>
           <div className="h-[400px] w-full">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={data.usageStats}>
                  <defs>
                    <linearGradient id="colorCount" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#80CBC4" stopOpacity={0.2}/>
                      <stop offset="95%" stopColor="#80CBC4" stopOpacity={0}/>
                    </linearGradient>
                  </defs>
                  <CartesianGrid vertical={false} stroke="rgba(255,255,255,0.03)" />
                  <XAxis dataKey="date" stroke="#ffffff20" fontSize={10} tickLine={false} axisLine={false} dy={10} />
                  <YAxis stroke="#ffffff20" fontSize={10} tickLine={false} axisLine={false} />
                  <Tooltip 
                    contentStyle={{ backgroundColor: '#101010', border: '1px solid rgba(255,255,255,0.05)', borderRadius: '16px', fontWeight: '800', color: '#fff' }} 
                    itemStyle={{ color: '#fff' }}
                    labelStyle={{ color: '#80CBC4' }}
                  />
                  <Area type="monotone" dataKey="count" stroke="#80CBC4" strokeWidth={4} fillOpacity={1} fill="url(#colorCount)" />
                </AreaChart>
              </ResponsiveContainer>
           </div>
        </div>

        <div className="glass-card p-10 rounded-[3rem] border-white/[0.03]">
           <div className="flex items-center justify-between mb-12">
              <div className="flex items-center gap-4">
                 <Activity className="w-6 h-6 text-secondary" />
                 <h3 className="text-2xl font-black text-foreground tracking-tighter">System Stability</h3>
              </div>
              <p className="text-[10px] font-black text-secondary uppercase tracking-[0.2em]">Target: 92.4% Optimal</p>
           </div>
           <div className="h-[400px] w-full">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={data.confidenceTrend}>
                  <CartesianGrid vertical={false} stroke="rgba(255,255,255,0.03)" />
                  <XAxis dataKey="date" stroke="#ffffff20" fontSize={10} tickLine={false} axisLine={false} dy={10} />
                  <YAxis domain={[80, 100]} stroke="#ffffff20" fontSize={10} tickLine={false} axisLine={false} />
                  <Tooltip 
                    contentStyle={{ backgroundColor: '#101010', border: '1px solid rgba(255,255,255,0.05)', borderRadius: '16px', fontWeight: '800', color: '#fff' }} 
                    itemStyle={{ color: '#fff' }}
                    labelStyle={{ color: '#80CBC4' }}
                  />
                  <Line type="stepAfter" dataKey="conf" stroke="#B39DDB" strokeWidth={4} dot={false} />
                </LineChart>
              </ResponsiveContainer>
           </div>
        </div>

        <div className="glass-card rounded-[3rem] overflow-hidden flex flex-col border-white/[0.03]">
           <div className="p-10 border-b border-white/5 bg-background/[0.01]">
              <h3 className="text-2xl font-black text-foreground tracking-tighter">Material Hierarchy</h3>
              <p className="text-muted-foreground text-sm font-bold tracking-tight">Most frequent architectural classifications.</p>
           </div>
           <div className="flex-1 overflow-auto">
              <table className="w-full text-left">
                <thead>
                  <tr className="text-muted-foreground text-[10px] uppercase tracking-[0.25em] font-black bg-zinc-950/30">
                    <th className="px-10 py-6">Signature</th>
                    <th className="px-10 py-6">Volume</th>
                    <th className="px-10 py-6">Market Share</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-white/5">
                  {data.topClasses.map((item, i) => (
                    <tr key={i} className="hover:bg-background/[0.02] transition-colors">
                      <td className="px-10 py-6">
                         <div className="flex items-center gap-4">
                            <div className="w-3 h-3 rounded-full shadow-[0_0_10px_rgba(128,203,196,0.5)]" style={{ backgroundColor: COLORS[i % COLORS.length] }} />
                            <span className="text-sm font-black text-foreground tracking-tight">{item.name}</span>
                         </div>
                      </td>
                      <td className="px-10 py-6 text-sm text-muted-foreground font-black font-mono">{item.value.toLocaleString()}</td>
                      <td className="px-10 py-6">
                         <div className="flex items-center gap-6">
                            <div className="w-28 bg-background/5 rounded-full h-1.5 overflow-hidden border border-white/5">
                               <div className="h-full rounded-full" style={{ width: `${(item.value / 5000) * 100}%`, backgroundColor: COLORS[i % COLORS.length] }} />
                            </div>
                            <span className="text-[10px] font-black text-muted-foreground uppercase tracking-widest">{((item.value / 5000) * 100).toFixed(1)}%</span>
                         </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
           </div>
        </div>

        <div className="glass-card p-10 rounded-[3rem] flex flex-col border-white/[0.03]">
           <div className="flex items-center gap-4 mb-12">
              <Layers className="w-6 h-6 text-secondary" />
              <h3 className="text-2xl font-black text-foreground tracking-tighter">Variant Spread</h3>
           </div>
           <div className="flex-1 h-[350px] w-full">
              <ResponsiveContainer width="100%" height="100%">
                <RadarChart cx="50%" cy="50%" outerRadius="80%" data={data.subclassFrequency}>
                  <PolarGrid stroke="rgba(255,255,255,0.05)" />
                  <PolarAngleAxis dataKey="name" tick={{ fill: 'rgba(255,255,255,0.3)', fontSize: 10, fontWeight: 800 }} />
                  <PolarRadiusAxis angle={30} domain={[0, 'auto']} hide />
                  <Radar name="Variants" dataKey="count" stroke="#B39DDB" fill="#B39DDB" fillOpacity={0.4} />
                  <Tooltip 
                    contentStyle={{ backgroundColor: '#101010', border: '1px solid rgba(255,255,255,0.05)', borderRadius: '16px', fontWeight: '800', color: '#fff' }} 
                    itemStyle={{ color: '#fff' }}
                    labelStyle={{ color: '#80CBC4' }}
                  />
                </RadarChart>
              </ResponsiveContainer>
           </div>
        </div>

        <div className="glass-card p-10 rounded-[3rem] flex flex-col border-white/[0.03]">
           <div className="flex items-center gap-4 mb-12">
              <PieChartIcon className="w-6 h-6 text-primary" />
              <h3 className="text-2xl font-black text-foreground tracking-tighter">Sector Exposure</h3>
           </div>
           <div className="flex-1 h-[350px] w-full">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie data={data.classDistribution} cx="50%" cy="50%" innerRadius={80} outerRadius={120} paddingAngle={8} dataKey="value">
                    {data.classDistribution.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} stroke="none" />)}
                  </Pie>
                  <Tooltip 
                    contentStyle={{ backgroundColor: '#101010', border: '1px solid rgba(255,255,255,0.05)', borderRadius: '16px', fontWeight: '800', color: '#fff' }} 
                    itemStyle={{ color: '#fff' }}
                    labelStyle={{ color: '#80CBC4' }}
                  />
                </PieChart>
              </ResponsiveContainer>
           </div>
           <div className="grid grid-cols-2 gap-6 mt-10">
              {data.topClasses.slice(0, 4).map((item, i) => (
                <div key={i} className="flex items-center gap-3">
                   <div className="w-3 h-3 rounded-full" style={{ backgroundColor: COLORS[i % COLORS.length] }} />
                   <span className="text-[10px] font-black text-muted-foreground uppercase tracking-[0.2em] truncate">{item.name}</span>
                </div>
              ))}
           </div>
        </div>
      </div>
    </div>
  );
};

export default Analytics;
