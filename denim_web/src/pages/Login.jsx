import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useNavigate, Link } from 'react-router-dom';
import axios from 'axios';
import { useAuthStore } from '../store/authStore';
import { ArrowRight, Mail, Lock, ShieldCheck, Sparkles, Layers, CheckCircle2, AlertCircle, Loader2 } from 'lucide-react';
import InteractiveDots from '../components/InteractiveDots';

const Login = () => {
  const navigate = useNavigate();
  const { login } = useAuthStore();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const res = await axios.post('http://localhost:5000/api/auth/login', { email, password });
      login(res.data.user, res.data.token);
      navigate('/dashboard');
    } catch (err) {
      setError(err.response?.data?.msg || 'Authentication failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen bg-background font-manrope relative overflow-hidden">
      <InteractiveDots />
      {/* Branding Panel (Teal Gradient) */}
      <div className="hidden lg:flex lg:w-1/2 relative bg-[#1E1E1E] overflow-hidden items-center justify-center">
        <div className="absolute inset-0 bg-gradient-to-br from-primary/20 via-transparent to-secondary/20" />
        <div className="absolute inset-0 bg-[url('https://grainy-gradients.vercel.app/noise.svg')] opacity-30 mix-blend-overlay" />
        
        <div className="relative z-10 p-20 max-w-xl">
          <motion.div 
            initial={{ opacity: 0, x: -20 }} animate={{ opacity: 1, x: 0 }}
            className="flex items-center gap-4 mb-12"
          >
            <div className="w-12 h-12 bg-primary rounded-2xl flex items-center justify-center shadow-2xl shadow-primary/30">
              <Layers className="w-7 h-7 text-black" />
            </div>
            <span className="text-3xl font-black text-foreground tracking-tighter">DenimAI</span>
          </motion.div>

          <h1 className="text-6xl font-black text-foreground leading-tight tracking-tighter mb-8">
            The Hub for <br />
            <span className="text-primary underline decoration-primary/30 underline-offset-8">Neural Fabric</span> <br />
            Research.
          </h1>

          <div className="space-y-6">
             {[
               { icon: <CheckCircle2 className="w-5 h-5 text-primary" />, text: "Automated hierarchical classification" },
               { icon: <CheckCircle2 className="w-5 h-5 text-primary" />, text: "Grad-CAM explainable AI heatmaps" },
               { icon: <CheckCircle2 className="w-5 h-5 text-primary" />, text: "Industrial-scale batch processing" }
             ].map((item, i) => (
               <motion.div 
                 key={i} initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 * i }}
                 className="flex items-center gap-4 text-muted-foreground/70 font-bold"
               >
                 {item.icon}
                 <span className="text-sm tracking-tight">{item.text}</span>
               </motion.div>
             ))}
          </div>
        </div>

        {/* Floating Abstract Shape */}
        <div className="absolute -bottom-20 -left-20 w-96 h-96 bg-primary/10 rounded-full blur-[100px]" />
      </div>

      {/* Form Panel */}
      <div className="w-full lg:w-1/2 flex flex-col items-center justify-center p-8 sm:p-20 relative">
        <div className="w-full max-w-md space-y-10">
          <div className="text-center lg:text-left">
             <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-primary/10 text-primary text-[10px] font-black uppercase tracking-widest mb-6">
                <ShieldCheck className="w-3 h-3" /> Secure Gateway
             </div>
             <h2 className="text-4xl font-black text-foreground tracking-tighter mb-3">Welcome back.</h2>
             <p className="text-muted-foreground font-bold text-sm">Sign in to your enterprise research workspace.</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-6">
            <AnimatePresence>
              {error && (
                <motion.div 
                  initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }} exit={{ opacity: 0, height: 0 }}
                  className="p-4 rounded-2xl bg-red-500/10 border border-red-500/20 flex items-center gap-3 text-red-500 text-sm font-bold"
                >
                  <AlertCircle className="w-5 h-5" />
                  {error}
                </motion.div>
              )}
            </AnimatePresence>

            <div className="space-y-4">
              <div className="relative group">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-muted-foreground group-focus-within:text-primary transition-colors">
                  <Mail className="w-5 h-5" />
                </div>
                <input
                  type="email"
                  required
                  placeholder="name@company.com"
                  className="input-field pl-12"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                />
              </div>

              <div className="relative group">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-muted-foreground group-focus-within:text-primary transition-colors">
                  <Lock className="w-5 h-5" />
                </div>
                <input
                  type="password"
                  required
                  placeholder="••••••••"
                  className="input-field pl-12"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                />
              </div>
            </div>

            <div className="flex items-center justify-between text-xs font-bold text-muted-foreground">
               <label className="flex items-center gap-2 cursor-pointer hover:text-foreground transition-colors">
                  <input type="checkbox" className="w-4 h-4 rounded-md bg-background/5 border-white/10 text-primary focus:ring-0 focus:ring-offset-0" />
                  Remember device
               </label>
               <a href="#" className="hover:text-primary transition-colors">Forgot password?</a>
            </div>

            <button
              disabled={loading}
              type="submit"
              className="primary-button w-full py-4 text-lg group"
            >
              {loading ? <Loader2 className="w-6 h-6 animate-spin" /> : (
                <>
                  Enter Workspace
                  <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
                </>
              )}
            </button>
          </form>

          <p className="text-center text-sm font-bold text-muted-foreground">
            Don't have an account? <Link to="/register" className="text-foreground hover:text-primary transition-colors">Create account</Link>
          </p>
        </div>
      </div>
    </div>
  );
};

export default Login;
