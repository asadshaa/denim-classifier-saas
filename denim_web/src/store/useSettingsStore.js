import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export const useSettingsStore = create(
  persist(
    (set) => ({
      enableHeatmap: true,
      showTopK: false,
      topKValue: 3,
      confidenceThreshold: 85,
      predictionMode: 'balanced', // 'strict', 'balanced', 'exploratory'
      computeNode: 't4', // 't4', 'h100'
      activeLearning: true,
      batchProcessing: false,
      theme: 'light', // 'light' or 'dark'
      
      setSettings: (newSettings) => set((state) => ({ ...state, ...newSettings })),
    }),
    {
      name: 'denimai-settings', // name of item in localStorage
    }
  )
);
