import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Link, useNavigate } from 'react-router-dom';
import { useAuthStore } from '../store/authStore';
import API_URL from '../api';
import { ArrowRight, Loader2, Layers, CheckCircle2, ShieldCheck, Mail, Lock, User, Sparkles } from 'lucide-react';
import axios from 'axios';
import InteractiveDots from '../components/InteractiveDots';

const Register = () => {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
  });
  const [isLoading, setIsLoading] = useState(false);
  const login = useAuthStore((state) => state.login);
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    try {
      const res = await axios.post(`${API_URL}/api/auth/register`, formData);
      login(res.data.user, res.data.token);
      navigate('/dashboard');
    } catch (err) {
      console.error(err);
      alert(err.response?.data?.msg || 'Registration failed');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen bg-background font-manrope selection:bg-primary/30 relative overflow-hidden">
      <InteractiveDots />

      {/* Branding Panel */}
      <div className="hidden lg:flex lg:w-1/2 relative bg-[#1E1E1E] overflow-hidden items-center justify-center border-r border-white/5">
        <div className="absolute inset-0 bg-gradient-to-br from-primary/20 via-transparent to-secondary/20" />
        <div className="absolute inset-0 bg-[url('https://grainy-gradients.vercel.app/noise.svg')] opacity-30 mix-blend-overlay" />
        
        <div className="relative z-10 p-20 max-w-xl">
          <Link to="/" className="flex items-center gap-4 mb-12">
            <div className="w-16 h-16 bg-white rounded-2xl flex items-center justify-center shadow-2xl overflow-hidden border border-white/20">
              <img 
                src="/logo.png" 
                alt="US Denim Logo" 
                className="w-full h-full object-contain p-1"
                onError={(e) => {
                  e.target.style.display = 'none';
                  e.target.parentElement.innerHTML = '<div class="text-[#215273] font-black text-xl">UD</div>';
                }}
              />
            </div>
            <span className="text-3xl font-black text-white tracking-tighter">DenimAI</span>
          </Link>

          <h1 className="text-6xl font-black text-primary leading-tight tracking-tighter mb-8">
            Join the <br />
            <span className="text-white underline decoration-white/30 underline-offset-8">Neural Revolution</span> <br />
            in Textiles.
          </h1>

          <div className="space-y-6">
             {[
               "Enterprise-grade inference cluster",
               "Real-time XAI explainability",
               "Multi-head material taxonomy",
               "Cloud-scale dataset management"
             ].map((text, i) => (
               <motion.div 
                 key={i} initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 * i }}
                 className="flex items-center gap-4 text-primary/80 font-bold"
               >
                 <CheckCircle2 className="w-5 h-5 text-primary" />
                 <span className="text-sm tracking-tight">{text}</span>
               </motion.div>
             ))}
          </div>
        </div>

        <div className="absolute -bottom-20 -left-20 w-96 h-96 bg-primary/10 rounded-full blur-[100px]" />
      </div>

      {/* Form Panel */}
      <div className="w-full lg:w-1/2 flex flex-col items-center justify-center p-8 sm:p-20 relative">
        <div className="w-full max-w-md space-y-10">
          <div className="text-center lg:text-left">
             <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-primary/10 text-primary text-[10px] font-black uppercase tracking-widest mb-6">
                <Sparkles className="w-3 h-3" /> Early Access
             </div>
             <h2 className="text-4xl font-black text-foreground tracking-tighter mb-3">Create Research Account.</h2>
             <p className="text-muted-foreground font-bold text-sm">Start your 14-day premium textile intelligence trial.</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-6">
            <div className="space-y-4">
              <div className="relative group">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-muted-foreground group-focus-within:text-primary transition-colors">
                  <User className="w-5 h-5" />
                </div>
                <input
                  type="text"
                  required
                  placeholder="Full Name"
                  className="input-field pl-12"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                />
              </div>

              <div className="relative group">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-muted-foreground group-focus-within:text-primary transition-colors">
                  <Mail className="w-5 h-5" />
                </div>
                <input
                  type="email"
                  required
                  placeholder="Work Email"
                  className="input-field pl-12"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                />
              </div>

              <div className="relative group">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-muted-foreground group-focus-within:text-primary transition-colors">
                  <Lock className="w-5 h-5" />
                </div>
                <input
                  type="password"
                  required
                  placeholder="Create Secure Password"
                  className="input-field pl-12"
                  value={formData.password}
                  onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                />
              </div>
            </div>

            <button
              disabled={isLoading}
              type="submit"
              className="primary-button w-full py-4 text-lg group"
            >
              {isLoading ? <Loader2 className="w-6 h-6 animate-spin" /> : (
                <>
                  Initialize Account
                  <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
                </>
              )}
            </button>
          </form>

          <p className="text-center text-sm font-bold text-muted-foreground">
            Already have an account? <Link to="/login" className="text-foreground hover:text-primary transition-colors">Sign in</Link>
          </p>
        </div>
      </div>
    </div>
  );
};

export default Register;
