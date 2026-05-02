import React, { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { useAuthStore } from '../store/authStore';
import { BrainCircuit, Activity, Target, ShieldCheck, Zap, Layers, Sparkles, Clock, TrendingUp, AlertTriangle } from 'lucide-react';
import axios from 'axios';
import {
  LineChart, Line, AreaChart, Area,
  BarChart, Bar,
  XAxis, YAxis, CartesianGrid, Tooltip as RechartsTooltip,
  ResponsiveContainer, Cell, ReferenceLine
} from 'recharts';

const CHART_STYLE = {
  contentStyle: {
    backgroundColor: 'var(--color-card)',
    border: '1px solid var(--color-border)',
    borderRadius: '16px',
    fontWeight: '800',
    color: 'var(--color-foreground)',
    fontSize: '11px'
  },
  labelStyle: { color: 'var(--color-muted-foreground)' },
  cursor: { fill: 'rgba(255,255,255,0.03)' }
};

const EmptyState = ({ icon: Icon, title, message }) => (
  <div className="flex flex-col items-center justify-center h-[250px] gap-4">
    <div className="w-14 h-14 rounded-2xl bg-muted/50 flex items-center justify-center">
      <Icon className="w-7 h-7 text-muted-foreground/40" />
    </div>
    <div className="text-center">
      <p className="font-black text-foreground text-sm">{title}</p>
      <p className="text-xs text-muted-foreground font-bold mt-1">{message}</p>
    </div>
  </div>
);

const KpiCard = ({ label, value, sub, icon: Icon, color, delay }) => (
  <motion.div
    initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay }}
    className="glass-card p-8 rounded-[2.5rem] hover:border-border transition-all group"
  >
    <div className={`p-3 rounded-2xl w-fit mb-6 ${color}`}>
      <Icon className="w-5 h-5" />
    </div>
    <p className="text-muted-foreground text-[10px] font-black uppercase tracking-[0.25em] mb-1">{label}</p>
    <p className="text-4xl font-black text-foreground tracking-tighter group-hover:scale-105 transition-transform origin-left">{value}</p>
    {sub && <p className="text-xs text-muted-foreground font-bold mt-2">{sub}</p>}
  </motion.div>
);

const ModelInsights = () => {
  const { isAuthenticated } = useAuthStore();
  const [trainingMetrics, setTrainingMetrics] = useState([]);
  const [confusionMatrix, setConfusionMatrix] = useState([]);
  const [report, setReport] = useState(null);
  const [performance, setPerformance] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchAll = async () => {
      try {
        const config = { headers: { Authorization: `Bearer ${localStorage.getItem('token')}` } };
        const [metricsRes, cmRes, perfRes] = await Promise.all([
          axios.get('http://localhost:5000/api/analytics/model-metrics', config),
          axios.get('http://localhost:5000/api/analytics/confusion-matrix', config),
          axios.get('http://localhost:5000/api/analytics/performance', config),
        ]);
        setTrainingMetrics(metricsRes.data.metrics || []);
        setReport(metricsRes.data.classificationReport);
        setConfusionMatrix(cmRes.data || []);
        setPerformance(perfRes.data);
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    if (isAuthenticated) fetchAll();
  }, [isAuthenticated]);

  const classes = [...new Set(confusionMatrix.map(item => item.actual))];

  const getHeatmapColor = (value, isDiagonal) => {
    if (value === 0) return 'bg-muted/30';
    if (isDiagonal) {
      if (value > 440) return 'bg-primary shadow-[0_0_12px_rgba(128,203,196,0.5)]';
      if (value > 430) return 'bg-primary/80';
      return 'bg-primary/60';
    } else {
      if (value > 3) return 'bg-orange-500';
      if (value > 1) return 'bg-orange-500/60';
      return 'bg-orange-500/30';
    }
  };

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] gap-6">
        <motion.div animate={{ rotate: 360 }} transition={{ duration: 1.2, repeat: Infinity, ease: "linear" }}>
          <BrainCircuit className="w-10 h-10 text-primary" />
        </motion.div>
        <p className="text-muted-foreground font-black text-xs uppercase tracking-widest">Loading Model Intelligence...</p>
      </div>
    );
  }

  const hasPerformanceData = performance?.latencyStats?.totalPredictions > 0;
  const hasFeedbackData = performance?.accuracyOverTime?.length > 0;
  const hasClassAccuracy = performance?.classAccuracy?.length > 0;

  return (
    <div className="space-y-10 pb-20 font-manrope animate-in">

      {/* Header */}
      <div>
        <div className="flex items-center gap-2 text-primary font-black text-[10px] uppercase tracking-[0.3em] mb-4">
          <BrainCircuit className="w-4 h-4" /> Neural Architecture Audit
        </div>
        <h1 className="text-5xl font-black text-foreground tracking-tighter">Model Intelligence</h1>
        <p className="text-muted-foreground mt-2 font-bold">Live performance monitoring and structural analysis from your production database.</p>
      </div>

      {/* Live System KPIs */}
      <div>
        <h2 className="text-xs font-black text-muted-foreground uppercase tracking-[0.3em] mb-4">⚡ System Performance — Live</h2>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
          <KpiCard
            label="Avg Inference Latency"
            value={hasPerformanceData ? `${performance.latencyStats.avgLatency.toFixed(1)}ms` : '—'}
            sub={hasPerformanceData ? `Min ${performance.latencyStats.minLatency.toFixed(0)}ms / Max ${performance.latencyStats.maxLatency.toFixed(0)}ms` : 'No latency data yet'}
            icon={Clock}
            color="bg-primary/10 text-primary"
            delay={0}
          />
          <KpiCard
            label="Total Predictions"
            value={performance?.latencyStats?.totalPredictions ?? '—'}
            sub="Stored in MongoDB"
            icon={Activity}
            color="bg-secondary/10 text-secondary"
            delay={0.05}
          />
          <KpiCard
            label="Overall F1-Score"
            value={report ? `${(report.f1 * 100).toFixed(1)}%` : '—'}
            sub="Training classification report"
            icon={Target}
            color="bg-emerald-500/10 text-emerald-500"
            delay={0.1}
          />
          <KpiCard
            label="Training Support"
            value={report ? report.support.toLocaleString() : '—'}
            sub="Total training samples"
            icon={Zap}
            color="bg-orange-500/10 text-orange-500"
            delay={0.15}
          />
        </div>
      </div>

      {/* Row 1: Accuracy Over Time + Confidence Drift */}
      <div className="grid lg:grid-cols-2 gap-8">

        {/* Accuracy Over Time */}
        <div className="glass-card p-8 rounded-[3rem]">
          <div className="mb-8">
            <h3 className="text-xl font-black text-foreground tracking-tighter flex items-center gap-3">
              <TrendingUp className="w-5 h-5 text-emerald-500" /> Accuracy Over Time
            </h3>
            <p className="text-xs text-muted-foreground font-bold mt-1">Computed from user ✅/❌ feedback in DB</p>
          </div>
          {hasFeedbackData ? (
            <div className="h-[250px]">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={performance.accuracyOverTime}>
                  <defs>
                    <linearGradient id="gradAcc" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#10b981" stopOpacity={0.25} />
                      <stop offset="95%" stopColor="#10b981" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid vertical={false} stroke="var(--color-border)" strokeOpacity={0.5} />
                  <XAxis dataKey="date" stroke="transparent" fontSize={10} tick={{ fill: 'var(--color-muted-foreground)', fontWeight: 800 }} tickLine={false} />
                  <YAxis domain={[0, 100]} stroke="transparent" fontSize={10} tick={{ fill: 'var(--color-muted-foreground)', fontWeight: 800 }} tickLine={false} tickFormatter={v => `${v}%`} />
                  <RechartsTooltip {...CHART_STYLE} formatter={(v) => [`${v.toFixed(1)}%`, 'Accuracy']} />
                  <ReferenceLine y={80} stroke="#f59e0b" strokeDasharray="4 4" strokeOpacity={0.5} />
                  <Area type="monotone" dataKey="accuracy" stroke="#10b981" strokeWidth={3} fillOpacity={1} fill="url(#gradAcc)" dot={{ fill: '#10b981', r: 4 }} />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          ) : (
            <EmptyState icon={AlertTriangle} title="No Feedback Data Yet" message="Submit ✅/❌ feedback on the Result page to populate this chart." />
          )}
        </div>

        {/* Confidence Drift */}
        <div className="glass-card p-8 rounded-[3rem]">
          <div className="mb-8">
            <h3 className="text-xl font-black text-foreground tracking-tighter flex items-center gap-3">
              <Activity className="w-5 h-5 text-secondary" /> Confidence Drift Detection
            </h3>
            <p className="text-xs text-muted-foreground font-bold mt-1">Avg model confidence per day — drift signals degradation</p>
          </div>
          {performance?.confidenceDrift?.length > 0 ? (
            <div className="h-[250px]">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={performance.confidenceDrift}>
                  <CartesianGrid vertical={false} stroke="var(--color-border)" strokeOpacity={0.5} />
                  <XAxis dataKey="date" stroke="transparent" fontSize={10} tick={{ fill: 'var(--color-muted-foreground)', fontWeight: 800 }} tickLine={false} />
                  <YAxis domain={[0, 100]} stroke="transparent" fontSize={10} tick={{ fill: 'var(--color-muted-foreground)', fontWeight: 800 }} tickLine={false} tickFormatter={v => `${v}%`} />
                  <RechartsTooltip {...CHART_STYLE} formatter={(v) => [`${v.toFixed(1)}%`, 'Avg Confidence']} />
                  <ReferenceLine y={80} stroke="#f59e0b" strokeDasharray="4 4" strokeOpacity={0.6} label={{ value: 'Threshold', fill: '#f59e0b', fontSize: 9 }} />
                  <Line type="monotone" dataKey="avgConfidence" stroke="#B39DDB" strokeWidth={3} dot={{ fill: '#B39DDB', r: 4 }} />
                </LineChart>
              </ResponsiveContainer>
            </div>
          ) : (
            <EmptyState icon={Activity} title="No Drift Data Yet" message="Start scanning to see confidence trends over time." />
          )}
        </div>
      </div>

      {/* Row 2: Confidence Distribution + Class-wise Accuracy */}
      <div className="grid lg:grid-cols-2 gap-8">

        {/* Confidence Distribution Histogram */}
        <div className="glass-card p-8 rounded-[3rem]">
          <div className="mb-8">
            <h3 className="text-xl font-black text-foreground tracking-tighter flex items-center gap-3">
              <ShieldCheck className="w-5 h-5 text-primary" /> Confidence Distribution
            </h3>
            <p className="text-xs text-muted-foreground font-bold mt-1">Histogram of all {performance?.latencyStats?.totalPredictions || 0} predictions in the database</p>
          </div>
          {performance?.confidenceDistribution?.some(b => b.count > 0) ? (
            <div className="h-[250px]">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={performance.confidenceDistribution} margin={{ left: -10 }}>
                  <CartesianGrid vertical={false} stroke="var(--color-border)" strokeOpacity={0.5} />
                  <XAxis dataKey="range" stroke="transparent" fontSize={9} tick={{ fill: 'var(--color-muted-foreground)', fontWeight: 800 }} tickLine={false} />
                  <YAxis stroke="transparent" fontSize={10} tick={{ fill: 'var(--color-muted-foreground)', fontWeight: 800 }} tickLine={false} allowDecimals={false} />
                  <RechartsTooltip {...CHART_STYLE} formatter={(v) => [v, 'Predictions']} />
                  <Bar dataKey="count" radius={[6, 6, 0, 0]} barSize={28}>
                    {performance.confidenceDistribution.map((entry, index) => {
                      // Color: red for low confidence, amber for medium, green for high
                      const color = index < 5 ? '#ef4444' : index < 7 ? '#f59e0b' : '#10b981';
                      return <Cell key={index} fill={color} fillOpacity={0.85} />;
                    })}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            </div>
          ) : (
            <EmptyState icon={ShieldCheck} title="No Predictions Yet" message="Upload images to populate the confidence histogram." />
          )}
        </div>

        {/* Class-wise Accuracy */}
        <div className="glass-card p-8 rounded-[3rem]">
          <div className="mb-8">
            <h3 className="text-xl font-black text-foreground tracking-tighter flex items-center gap-3">
              <Target className="w-5 h-5 text-orange-500" /> Class-wise Accuracy
            </h3>
            <p className="text-xs text-muted-foreground font-bold mt-1">Verified via user feedback — only includes reviewed predictions</p>
          </div>
          {hasClassAccuracy ? (
            <div className="h-[250px]">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={performance.classAccuracy} layout="vertical" margin={{ left: 10, right: 20 }}>
                  <CartesianGrid horizontal={false} stroke="var(--color-border)" strokeOpacity={0.5} />
                  <XAxis type="number" domain={[0, 100]} stroke="transparent" fontSize={10} tick={{ fill: 'var(--color-muted-foreground)', fontWeight: 800 }} tickLine={false} tickFormatter={v => `${v}%`} />
                  <YAxis type="category" dataKey="class" width={80} stroke="transparent" fontSize={9} tick={{ fill: 'var(--color-muted-foreground)', fontWeight: 800 }} tickLine={false} />
                  <RechartsTooltip {...CHART_STYLE} formatter={(v) => [`${v.toFixed(1)}%`, 'Accuracy']} />
                  <Bar dataKey="accuracy" radius={[0, 8, 8, 0]} barSize={18}>
                    {performance.classAccuracy.map((entry, index) => {
                      const color = entry.accuracy >= 90 ? '#10b981' : entry.accuracy >= 70 ? '#f59e0b' : '#ef4444';
                      return <Cell key={index} fill={color} fillOpacity={0.85} />;
                    })}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            </div>
          ) : (
            <EmptyState icon={Target} title="No Feedback Yet" message="Verify predictions on the Result page to see per-class accuracy." />
          )}
        </div>
      </div>

      {/* Row 3: Training History */}
      <div className="grid lg:grid-cols-2 gap-8">
        <div className="glass-card p-8 rounded-[3rem]">
          <div className="flex items-center justify-between mb-8">
            <h3 className="text-xl font-black text-foreground tracking-tighter">Training — Accuracy Convergence</h3>
            <div className="flex gap-4">
              <div className="flex items-center gap-1.5 text-[10px] font-black text-primary uppercase tracking-widest">
                <span className="w-2 h-2 rounded-full bg-primary" /> Train
              </div>
              <div className="flex items-center gap-1.5 text-[10px] font-black text-emerald-500 uppercase tracking-widest">
                <span className="w-2 h-2 rounded-full bg-emerald-500" /> Val
              </div>
            </div>
          </div>
          <div className="h-[250px]">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={trainingMetrics}>
                <defs>
                  <linearGradient id="colorAcc2" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#80CBC4" stopOpacity={0.2} />
                    <stop offset="95%" stopColor="#80CBC4" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid vertical={false} stroke="var(--color-border)" strokeOpacity={0.5} />
                <XAxis dataKey="epoch" stroke="transparent" fontSize={10} tick={{ fill: 'var(--color-muted-foreground)', fontWeight: 800 }} tickLine={false} />
                <YAxis domain={[0, 100]} stroke="transparent" fontSize={10} tick={{ fill: 'var(--color-muted-foreground)', fontWeight: 800 }} tickLine={false} />
                <RechartsTooltip {...CHART_STYLE} />
                <Area type="monotone" dataKey="acc" stroke="#80CBC4" strokeWidth={3} fillOpacity={1} fill="url(#colorAcc2)" />
                <Area type="monotone" dataKey="val_acc" stroke="#10b981" strokeWidth={3} fill="transparent" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="glass-card p-8 rounded-[3rem]">
          <div className="flex items-center justify-between mb-8">
            <h3 className="text-xl font-black text-foreground tracking-tighter">Training — Loss Minimization</h3>
            <div className="flex gap-4">
              <div className="flex items-center gap-1.5 text-[10px] font-black text-orange-500 uppercase tracking-widest">
                <span className="w-2 h-2 rounded-full bg-orange-500" /> Train
              </div>
              <div className="flex items-center gap-1.5 text-[10px] font-black text-secondary uppercase tracking-widest">
                <span className="w-2 h-2 rounded-full bg-secondary" /> Val
              </div>
            </div>
          </div>
          <div className="h-[250px]">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={trainingMetrics}>
                <CartesianGrid vertical={false} stroke="var(--color-border)" strokeOpacity={0.5} />
                <XAxis dataKey="epoch" stroke="transparent" fontSize={10} tick={{ fill: 'var(--color-muted-foreground)', fontWeight: 800 }} tickLine={false} />
                <YAxis stroke="transparent" fontSize={10} tick={{ fill: 'var(--color-muted-foreground)', fontWeight: 800 }} tickLine={false} />
                <RechartsTooltip {...CHART_STYLE} />
                <Line type="monotone" dataKey="loss" stroke="#f97316" strokeWidth={3} dot={false} />
                <Line type="monotone" dataKey="val_loss" stroke="#B39DDB" strokeWidth={3} dot={false} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>

      {/* Confusion Matrix */}
      <div className="glass-card p-10 rounded-[4rem] overflow-hidden">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-6 mb-12">
          <div>
            <h3 className="text-3xl font-black text-foreground tracking-tighter">Interactive Confusion Matrix</h3>
            <p className="text-muted-foreground text-sm font-bold mt-1">Hover cells for misclassification details. Diagonal = correct predictions.</p>
          </div>
          <div className="flex items-center gap-6 px-6 py-3 rounded-2xl bg-muted/30 border border-border">
            <div className="flex items-center gap-2 text-[10px] font-black text-muted-foreground uppercase tracking-widest">
              <div className="w-3 h-3 rounded bg-muted/50" /> Baseline
            </div>
            <div className="flex items-center gap-2 text-[10px] font-black text-primary uppercase tracking-widest">
              <div className="w-3 h-3 rounded bg-primary shadow-[0_0_8px_rgba(128,203,196,0.8)]" /> Correct
            </div>
            <div className="flex items-center gap-2 text-[10px] font-black text-orange-500 uppercase tracking-widest">
              <div className="w-3 h-3 rounded bg-orange-500/70" /> Misclassified
            </div>
          </div>
        </div>

        <div className="overflow-x-auto pb-4">
          <div className="min-w-[700px] px-4">
            <div className="flex mb-6">
              <div className="w-36 shrink-0" />
              {classes.map(c => (
                <div key={`h-${c}`} className="flex-1 text-center text-[9px] font-black text-muted-foreground uppercase tracking-wider px-1 h-20 flex items-end justify-center pb-2" style={{ writingMode: 'vertical-lr', transform: 'rotate(180deg)' }}>
                  {c}
                </div>
              ))}
            </div>

            {classes.map(actualClass => (
              <div key={`row-${actualClass}`} className="flex items-center mb-1">
                <div className="w-36 shrink-0 text-right pr-4 text-[9px] font-black text-muted-foreground uppercase tracking-wider truncate">
                  {actualClass}
                </div>
                {classes.map(predClass => {
                  const cellData = confusionMatrix.find(i => i.actual === actualClass && i.predicted === predClass);
                  const value = cellData ? cellData.count : 0;
                  const isDiagonal = actualClass === predClass;
                  return (
                    <motion.div
                      key={`cell-${actualClass}-${predClass}`}
                      whileHover={{ scale: 1.2, zIndex: 10 }}
                      className={`flex-1 aspect-square m-[2px] rounded-lg flex items-center justify-center text-[9px] font-black text-foreground transition-all cursor-pointer ${getHeatmapColor(value, isDiagonal)}`}
                      title={`Actual: ${actualClass} → Predicted: ${predClass} | Count: ${value}`}
                    >
                      {value > 0 ? value : ''}
                    </motion.div>
                  );
                })}
              </div>
            ))}
            <div className="text-center text-[9px] font-black text-muted-foreground uppercase tracking-[0.4em] mt-6 opacity-50">
              Predicted Category →
            </div>
          </div>
        </div>
      </div>

      {/* Architecture Spec */}
      <div className="p-10 rounded-[4rem] bg-gradient-to-br from-primary/15 to-secondary/10 border border-border relative overflow-hidden group">
        <div className="relative z-10 grid md:grid-cols-3 gap-10">
          <div className="md:col-span-2">
            <div className="flex items-center gap-3 mb-4">
              <Sparkles className="w-5 h-5 text-primary" />
              <span className="text-[10px] font-black text-primary uppercase tracking-[0.4em]">Engine Specification</span>
            </div>
            <h3 className="text-4xl font-black text-foreground mb-4 tracking-tighter">EfficientNet-B0 (Multi-Head)</h3>
            <p className="text-muted-foreground text-sm font-bold leading-relaxed mb-8 max-w-2xl">
              Advanced convolutional feature extraction for textile micro-pattern recognition. The dual-head architecture independently resolves 21 main classes and 5 sub-variant categories from a single forward pass.
            </p>
            <div className="flex flex-wrap gap-3">
              {['ImageNet Weights', 'Fine-tuned v4', 'TFLite Optimized', '224×224 Input', 'Multi-Head Output'].map((tag, i) => (
                <span key={i} className="px-4 py-2 rounded-xl bg-background/10 border border-border/50 text-[10px] font-black text-foreground uppercase tracking-widest">
                  {tag}
                </span>
              ))}
            </div>
          </div>
          <div className="flex flex-col justify-center">
            <div className="p-8 rounded-[2.5rem] bg-background/20 border border-border/50 backdrop-blur-xl">
              <p className="text-muted-foreground text-[10px] font-black uppercase tracking-[0.2em] mb-4">Live Avg Latency</p>
              <div className="flex items-baseline gap-2">
                <span className="text-6xl font-black text-foreground tracking-tighter">
                  {hasPerformanceData ? performance.latencyStats.avgLatency.toFixed(0) : '—'}
                </span>
                <span className="text-lg text-primary font-black uppercase tracking-tighter">ms / img</span>
              </div>
              <div className="w-full bg-background/20 rounded-full h-1.5 mt-6 overflow-hidden">
                <motion.div
                  initial={{ width: 0 }}
                  animate={{ width: hasPerformanceData ? `${Math.min((performance.latencyStats.avgLatency / 500) * 100, 100)}%` : '0%' }}
                  transition={{ duration: 1.5, delay: 0.5 }}
                  className="bg-primary h-full rounded-full shadow-[0_0_12px_rgba(128,203,196,0.8)]"
                />
              </div>
              <p className="text-[9px] text-muted-foreground font-bold mt-2 uppercase tracking-widest">
                {hasPerformanceData ? 'Computed from DB' : 'Run predictions first'}
              </p>
            </div>
          </div>
        </div>
        <Layers className="absolute -bottom-10 -right-10 w-80 h-80 text-primary/5 rotate-12 pointer-events-none group-hover:rotate-45 transition-transform duration-1000" />
      </div>
    </div>
  );
};

export default ModelInsights;
