import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Landing from './pages/Landing';
import Login from './pages/Login';
import Register from './pages/Register';
import Dashboard from './pages/Dashboard';
import Upload from './pages/Upload';
import Result from './pages/Result';
import Analytics from './pages/Analytics';
import ActiveLearning from './pages/ActiveLearning';
import ModelInsights from './pages/ModelInsights';
import ClassComparison from './pages/ClassComparison';
import BatchResult from './pages/BatchResult';
import Settings from './pages/Settings';
import DatasetExplorer from './pages/DatasetExplorer';
import ABTesting from './pages/ABTesting';

import AppShell from './components/AppShell';
import { useSettingsStore } from './store/useSettingsStore';

function App() {
  const { theme } = useSettingsStore();
  return (
    <Router>
      <div className={`min-h-screen bg-background text-foreground transition-colors duration-300 ${theme === 'dark' ? 'dark' : ''}`}>
        <Routes>
          {/* Public Routes */}
          <Route path="/" element={<Landing />} />
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          
          {/* Protected Routes inside AppShell */}
          <Route element={<AppShell />}>
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/upload" element={<Upload />} />
            <Route path="/result" element={<Result />} />
            <Route path="/analytics" element={<Analytics />} />
            <Route path="/active-learning" element={<ActiveLearning />} />
            <Route path="/model-insights" element={<ModelInsights />} />
            <Route path="/compare" element={<ClassComparison />} />
            <Route path="/batch-result" element={<BatchResult />} />
            <Route path="/dataset" element={<DatasetExplorer />} />
            <Route path="/ab-testing" element={<ABTesting />} />
            <Route path="/settings" element={<Settings />} />
          </Route>

          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
