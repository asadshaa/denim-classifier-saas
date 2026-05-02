import React, { useEffect } from 'react';
import { motion } from 'framer-motion';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { useScanStore } from '../store/scanStore';
import { ArrowLeft, CheckCircle2, AlertTriangle, Download, PieChart as PieChartIcon, Activity, Sparkles, LayoutGrid, Layers, Target } from 'lucide-react';
import { PieChart, Pie, Cell, Tooltip, ResponsiveContainer, Legend, BarChart, Bar, XAxis, YAxis, CartesianGrid } from 'recharts';

const COLORS = ['#80CBC4', '#B39DDB', '#FFAB91', '#81C784', '#FFF176', '#4DB6AC'];

const BatchResult = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const { setCurrentScan } = useScanStore();
  const job = location.state?.job;

  useEffect(() => {
    if (!job) navigate('/dashboard');
  }, [job, navigate]);

  if (!job) return null;

  const successes = job.successes || [];
  const failures = job.failures || [];
  const avgConfidence = successes.length > 0 ? successes.reduce((acc, curr) => acc + curr.confidence_main, 0) / successes.length : 0;
  
  const distribution = {};
  successes.forEach(scan => { distribution[scan.main_class] = (distribution[scan.main_class] || 0) + 1; });
  const mostCommonClass = Object.keys(distribution).reduce((a, b) => distribution[a] > distribution[b] ? a : b, '-');
  const chartData = Object.keys(distribution).map(key => ({ name: key, value: distribution[key] })).sort((a, b) => b.value - a.value);

  const confBins = [
    { name: '90-100%', count: 0 },
    { name: '80-90%', count: 0 },
    { name: '70-80%', count: 0 },
    { name: 'Below 70%', count: 0 },
  ];
  
  successes.forEach(s => {
    if (s.confidence_main >= 0.9) confBins[0].count++;
    else if (s.confidence_main >= 0.8) confBins[1].count++;
    else if (s.confidence_main >= 0.7) confBins[2].count++;
    else confBins[3].count++;
  });

  const mostUncertain = [...successes].sort((a, b) => a.confidence_main - b.confidence_main).slice(0, 3);

  const handleExportCSV = () => {
    const headers = ['File', 'Class', 'Variant', 'Confidence', 'Status'];
    const rows = [headers.join(',')];
    successes.forEach(s => rows.push(`${s.imageUrl.split('/').pop()},${s.main_class},${s.subclass},${(s.confidence_main*100).toFixed(1)}%,Success`));
    failures.forEach(f => rows.push(`${f.file},N/A,N/A,N/A,Failed`));
    
    const csvContent = "\uFEFF" + rows.join('\n');
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.setAttribute('href', url);
    a.setAttribute('download', 'batch_report.csv');
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    window.URL.revokeObjectURL(url);
  };

  return (
    <div className="max-w-7xl mx-auto space-y-12 pb-20 animate-in font-manrope">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-6">
        <div>
           <div className="flex items-center gap-2 text-primary font-black text-[10px] uppercase tracking-[0.3em] mb-4">
             <Sparkles className="w-4 h-4 shadow-primary/50" /> Industrial Session Complete
          </div>
          <h1 className="text-5xl font-black text-foreground tracking-tighter">Research Summary</h1>
        </div>
        <div className="flex gap-4">
           <button onClick={handleExportCSV} className="secondary-button group border-white/[0.03]">
             <Download className="w-4 h-4 text-primary group-hover:translate-y-1 transition-transform" />
             Export Matrix
           </button>
           <div className="flex items-center gap-3 text-emerald-400 bg-emerald-400/10 border border-emerald-400/20 px-8 py-3 rounded-2xl font-black text-[10px] uppercase tracking-widest shadow-xl shadow-emerald-500/5">
             <CheckCircle2 className="w-4 h-4" /> Node Synchronized
           </div>
        </div>
      </div>

      {/* KPI Stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-8">
         {[
           { label: 'Samples Decoded', val: job.total, color: 'text-foreground' },
           { label: 'Success Rate', val: `${((successes.length / job.total) * 100).toFixed(0)}%`, color: 'text-emerald-400' },
           { label: 'System Precision', val: `${(avgConfidence * 100).toFixed(1)}%`, color: 'text-primary' },
           { label: 'Signatures Resolved', val: Object.keys(distribution).length, color: 'text-secondary' }
         ].map((stat, i) => (
           <div key={i} className="glass-card p-10 rounded-[3rem] border-white/[0.03]">
              <p className="text-[10px] font-black text-muted-foreground uppercase tracking-[0.25em] mb-3">{stat.label}</p>
              <p className={`text-5xl font-black ${stat.color} tracking-tighter`}>{stat.val}</p>
           </div>
         ))}
      </div>

      <div className="grid lg:grid-cols-12 gap-10">
        <div className="lg:col-span-8 grid md:grid-cols-2 gap-10">
           <div className="glass-card p-10 rounded-[3.5rem] flex flex-col border-white/[0.03]">
              <div className="flex items-center gap-4 mb-10">
                 <PieChartIcon className="w-6 h-6 text-primary" />
                 <h3 className="text-xl font-black text-foreground tracking-tighter">Architecture Spread</h3>
              </div>
              <div className="flex-1 h-[280px] w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie data={chartData} cx="50%" cy="50%" innerRadius={70} outerRadius={100} paddingAngle={8} dataKey="value" stroke="none">
                      {chartData.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
                    </Pie>
                    <Tooltip 
                      contentStyle={{ backgroundColor: '#101010', border: '1px solid rgba(255,255,255,0.05)', borderRadius: '16px', fontWeight: '800', color: '#fff' }} 
                      itemStyle={{ color: '#fff' }}
                      labelStyle={{ color: '#80CBC4' }}
                    />
                  </PieChart>
                </ResponsiveContainer>
              </div>
           </div>

           <div className="glass-card p-10 rounded-[3.5rem] flex flex-col border-white/[0.03]">
              <div className="flex items-center gap-4 mb-10">
                 <Activity className="w-6 h-6 text-secondary" />
                 <h3 className="text-xl font-black text-foreground tracking-tighter">Confidence Tiers</h3>
              </div>
              <div className="flex-1 h-[280px] w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={confBins}>
                    <CartesianGrid vertical={false} stroke="rgba(255,255,255,0.03)" />
                    <XAxis dataKey="name" stroke="#ffffff10" fontSize={10} tickLine={false} axisLine={false} dy={10} />
                    <YAxis stroke="#ffffff10" fontSize={10} tickLine={false} axisLine={false} />
                    <Tooltip 
                      contentStyle={{ backgroundColor: '#101010', border: '1px solid rgba(255,255,255,0.05)', borderRadius: '16px', fontWeight: '800', color: '#fff' }}
                      itemStyle={{ color: '#fff' }}
                      labelStyle={{ color: '#80CBC4' }}
                    />
                    <Bar dataKey="count" fill="#80CBC4" radius={[8, 8, 0, 0]} barSize={40} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
           </div>
        </div>

        <div className="lg:col-span-4 space-y-8">
           <div className="glass-card p-10 rounded-[3.5rem] border-orange-500/10 bg-orange-500/[0.02]">
              <div className="flex items-center gap-4 mb-8">
                 <AlertTriangle className="w-6 h-6 text-orange-400" />
                 <h3 className="text-xl font-black text-foreground tracking-tighter">Review Required</h3>
              </div>
              <div className="space-y-6">
                {mostUncertain.map((s, i) => (
                  <div key={i} className="flex items-center gap-4 p-5 rounded-[2rem] bg-background/5 border border-white/5 hover:border-orange-500/40 transition-all cursor-pointer group" onClick={() => { setCurrentScan(s); navigate('/result'); }}>
                    <div className="w-14 h-14 rounded-2xl overflow-hidden shrink-0 border border-white/10 group-hover:scale-110 transition-transform shadow-2xl">
                       <img src={`http://localhost:5000${s.imageUrl}`} className="w-full h-full object-cover" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-foreground text-sm font-black truncate tracking-tight">{s.main_class}</p>
                      <p className="text-orange-400 text-[10px] font-black uppercase tracking-widest mt-1">{(s.confidence_main*100).toFixed(1)}% Confidence</p>
                    </div>
                  </div>
                ))}
              </div>
           </div>
        </div>

        {/* Detailed Table */}
        <div className="lg:col-span-12 glass-card rounded-[3.5rem] overflow-hidden border-white/[0.03]">
           <div className="p-10 border-b border-white/5 flex items-center justify-between bg-background/[0.01]">
              <div>
                <h3 className="text-2xl font-black text-foreground tracking-tighter">Session Matrix</h3>
                <p className="text-muted-foreground text-sm font-bold tracking-tight">Full deep-dive into the processed dataset.</p>
              </div>
              <div className="flex items-center gap-3 p-2 rounded-2xl bg-background/5 border border-white/5">
                 <button className="px-6 py-2.5 rounded-xl bg-primary text-black text-[10px] font-black uppercase tracking-widest shadow-lg">Matrix View</button>
                 <button className="px-6 py-2.5 rounded-xl text-muted-foreground text-[10px] font-black uppercase tracking-widest">Grid View</button>
              </div>
           </div>
           <div className="overflow-x-auto max-h-[700px]">
              <table className="w-full text-left">
                <thead className="bg-[#101010]/95 backdrop-blur-3xl sticky top-0 z-10 border-b border-white/5">
                  <tr className="text-muted-foreground text-[10px] uppercase tracking-[0.25em] font-black">
                    <th className="px-12 py-6">ID Signature</th>
                    <th className="px-12 py-6">Classification</th>
                    <th className="px-12 py-6">Variant</th>
                    <th className="px-12 py-6">Confidence Score</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-white/5">
                  {successes.map((scan) => (
                    <tr 
                      key={scan._id} 
                      onClick={() => { setCurrentScan(scan); navigate('/result'); }}
                      className="group hover:bg-background/[0.02] transition-all cursor-pointer"
                    >
                      <td className="px-12 py-8">
                        <div className="flex items-center gap-5">
                           <img src={`http://localhost:5000${scan.imageUrl}`} className="w-16 h-16 rounded-[1.5rem] object-cover border border-white/10 group-hover:scale-110 transition-transform shadow-2xl" />
                           <span className="text-[10px] font-black text-muted-foreground group-hover:text-foreground transition-colors tracking-widest">#{scan._id.slice(-8).toUpperCase()}</span>
                        </div>
                      </td>
                      <td className="px-12 py-8 text-sm font-black text-foreground tracking-tight">{scan.main_class}</td>
                      <td className="px-12 py-8 text-sm text-muted-foreground font-bold tracking-tight">V-{scan.subclass}</td>
                      <td className="px-12 py-8">
                        <div className="flex items-center gap-6">
                           <div className="w-32 bg-background/5 rounded-full h-1.5 overflow-hidden border border-white/5">
                              <div className={`h-full rounded-full ${scan.confidence_main < 0.85 ? 'bg-orange-400' : 'bg-primary'}`} style={{ width: `${scan.confidence_main * 100}%` }} />
                           </div>
                           <span className={`text-[10px] font-black ${scan.confidence_main < 0.85 ? 'text-orange-400' : 'text-muted-foreground'} uppercase tracking-widest`}>{(scan.confidence_main * 100).toFixed(0)}%</span>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
           </div>
        </div>
      </div>
    </div>
  );
};

export default BatchResult;
