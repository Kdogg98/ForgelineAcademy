import { createContext, useContext } from 'react';
import type { ThemeCompany } from './themeStore';

export type ThemeSource = 'member' | 'preview' | 'debug';

interface CompanyThemeValue {
  /** Company whose theme is applied site-wide, or null for the default ForgeLine look. */
  company: ThemeCompany | null;
  source: ThemeSource | null;
  /** Document title helper: "<page> | <Company> Academy | ForgeLine" when themed. */
  titleFor: (defaultTitle: string, page?: string | null) => string;
  /** Master admin only: preview the whole site as a company (persists for this tab). */
  startPreview: (company: ThemeCompany) => void;
  exitPreview: () => void;
}

export const CompanyThemeContext = createContext<CompanyThemeValue>({
  company: null,
  source: null,
  titleFor: (t) => t,
  startPreview: () => {},
  exitPreview: () => {},
});

export function useCompanyTheme() {
  return useContext(CompanyThemeContext);
}
