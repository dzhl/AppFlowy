import { ThemeMode } from '$app/stores/reducers/current-user/slice';
import { ThemeOptions } from '@mui/material';

// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-ignore
export const getDesignTokens = (mode: ThemeMode): ThemeOptions => {
  const isDark = mode === ThemeMode.Dark;

  return {
    typography: {
      fontFamily: ['Poppins'].join(','),
      fontSize: 12,
      button: {
        textTransform: 'none',
      },
    },
    components: {
      MuiMenuItem: {
        defaultProps: {
          sx: {
            '&.Mui-selected.Mui-focusVisible': {
              backgroundColor: 'var(--fill-list-hover)',
            },
            '&.Mui-focusVisible': {
              backgroundColor: 'unset',
            },
          },
        },
      },
      MuiIconButton: {
        styleOverrides: {
          root: {
            '&:hover': {
              backgroundColor: 'var(--fill-list-hover)',
            },
            borderRadius: '4px',
            padding: '2px',
          },
        },
      },
      MuiButton: {
        styleOverrides: {
          contained: {
            color: 'var(--content-on-fill)',
          },
          containedPrimary: {
            '&:hover': {
              backgroundColor: 'var(--fill-default)',
            },
          },
        },
      },
      MuiButtonBase: {
        defaultProps: {
          sx: {
            '&.Mui-selected:hover': {
              backgroundColor: 'var(--fill-list-hover)',
            },
          },
        },
        styleOverrides: {
          root: {
            '&:hover': {
              backgroundColor: 'var(--fill-list-hover)',
            },
            '&:active': {
              backgroundColor: 'var(--fill-list-hover)',
            },
            borderRadius: '4px',
            padding: '2px',
            boxShadow: 'none',
          },
        },
      },
      MuiPaper: {
        styleOverrides: {
          root: {
            backgroundImage: 'none',
          },
        },
      },
      MuiDialog: {
        defaultProps: {
          sx: {
            '& .MuiBackdrop-root': {
              backgroundColor: 'var(--bg-mask)',
            },
          },
        },
      },

      MuiTooltip: {
        styleOverrides: {
          arrow: {
            color: 'var(--bg-tips)',
          },
          tooltip: {
            backgroundColor: 'var(--bg-tips)',
            color: 'var(--text-title)',
            fontSize: '0.85rem',
            borderRadius: '8px',
            fontWeight: 400,
          },
        },
      },
      MuiInputBase: {
        styleOverrides: {
          input: {
            backgroundColor: 'transparent !important',
          },
        },
      },
      MuiDivider: {
        styleOverrides: {
          root: {
            borderColor: 'var(--line-divider)',
          },
        },
      },
    },
    palette: {
      mode: isDark ? 'dark' : 'light',
      primary: {
        main: '#00BCF0',
        dark: '#00BCF0',
      },
      error: {
        main: '#FB006D',
        dark: '#D32772',
      },
      warning: {
        main: '#FFC107',
        dark: '#E9B320',
      },
      info: {
        main: '#00BCF0',
        dark: '#2E9DBB',
      },
      success: {
        main: '#66CF80',
        dark: '#3BA856',
      },
      text: {
        primary: isDark ? '#E2E9F2' : '#333333',
        secondary: isDark ? '#7B8A9D' : '#828282',
        disabled: isDark ? '#363D49' : '#F2F2F2',
      },
      divider: isDark ? '#59647A' : '#BDBDBD',
      background: {
        default: isDark ? '#1A202C' : '#FFFFFF',
        paper: isDark ? '#1A202C' : '#FFFFFF',
      },
    },
  };
};
