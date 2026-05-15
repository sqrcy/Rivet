import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Rivet',
  tagline:
    'A top-level Roblox/Luau systems layer for managed ModuleScript Units, startup order, networking, contracts, codecs, cleanup, plugins, and benchmarks.',
  favicon: 'img/favicon.ico',

  future: {
    v4: true,
  },

  url: 'https://sqrcy.github.io',
  baseUrl: '/rivet/',

  organizationName: 'sqrcy',
  projectName: 'rivet',

  onBrokenLinks: 'throw',
  markdown: {
    hooks: {
      onBrokenMarkdownLinks: 'warn',
    },
  },

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          editUrl: 'https://github.com/sqrcy/rivet/tree/main/my-website/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    image: 'img/rivet-social-card.png',
    colorMode: {
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: 'Rivet',
      logo: {
        alt: 'Rivet Logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          to: '/docs/intro',
          position: 'left',
          label: 'Docs',
          activeBaseRegex: '^/docs/intro/?$',
        },
        {
          to: '/docs/getting-started/installation',
          position: 'left',
          label: 'Getting Started',
          activeBaseRegex: '^/docs/getting-started/',
        },
        {
          to: '/docs/advanced/codecs',
          position: 'left',
          label: 'Advanced',
          activeBaseRegex: '^/docs/advanced/',
        },
        {
          to: '/docs/benchmarks',
          position: 'left',
          label: 'Benchmarks',
          activeBaseRegex: '^/docs/benchmarks/?$',
        },
        {
          to: '/docs/api-reference',
          position: 'left',
          label: 'API',
          activeBaseRegex: '^/docs/api-reference/?$',
        },
        {
          href: 'https://github.com/sqrcy/rivet',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {
              label: 'Overview',
              to: '/docs/intro',
            },
            {
              label: 'Installation',
              to: '/docs/getting-started/installation',
            },
            {
              label: 'Networking',
              to: '/docs/core/networking',
            },
          ],
        },
        {
          title: 'Reference',
          items: [
            {
              label: 'Advanced Features',
              to: '/docs/advanced/codecs',
            },
            {
              label: 'Benchmarks',
              to: '/docs/benchmarks',
            },
            {
              label: 'API Reference',
              to: '/docs/api-reference',
            },
          ],
        },
        {
          title: 'Project',
          items: [
            {
              label: 'Changelog',
              href: 'https://github.com/sqrcy/rivet/blob/main/CHANGELOG.md',
            },
            {
              label: 'GitHub',
              href: 'https://github.com/sqrcy/rivet',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Rivet. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['lua', 'toml'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
