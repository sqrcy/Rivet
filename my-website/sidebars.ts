import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  docsSidebar: [
    {
      type: 'doc',
      id: 'intro',
      label: 'Rivet Overview',
    },
    {
      type: 'category',
      label: 'Getting Started',
      collapsed: false,
      items: [
        'getting-started/installation',
        'getting-started/first-unit',
        'getting-started/server-client-setup',
      ],
    },
    {
      type: 'category',
      label: 'Core Concepts',
      collapsed: false,
      items: [
        'core/units',
        'core/dependencies',
        'core/lifecycle-and-cleanup',
        'core/surfaces',
        'core/networking',
        'core/contracts',
      ],
    },
    {
      type: 'category',
      label: 'Advanced Features',
      collapsed: false,
      items: [
        'advanced/codecs',
        'advanced/plugins',
        'advanced/debugging-and-errors',
        'advanced/runtime-architecture',
      ],
    },
    {
      type: 'doc',
      id: 'benchmarks',
      label: 'Benchmarks',
    },
    {
      type: 'doc',
      id: 'api-reference',
      label: 'Full API Reference',
    },
  ],
};

export default sidebars;
