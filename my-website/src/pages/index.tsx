import type {ReactNode} from 'react';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

import styles from './index.module.css';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();

  return (
    <header className={styles.heroBanner}>
      <div className="container">
        <Heading as="h1" className={styles.heroTitle}>
          {siteConfig.title}
        </Heading>
        <p className={styles.heroSubtitle}>{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <Link
            className="button button--primary button--lg"
            to="/docs/getting-started/installation">
            Start building
          </Link>
          <Link
            className="button button--secondary button--lg"
            to="/docs/api-reference">
            Read the API
          </Link>
        </div>
        <pre className={styles.codeCard}>
          <code>{`local Rivet = require(ReplicatedStorage.Packages.Rivet)

Rivet.Start({
  Roots = {
    ReplicatedStorage.Units,
  },
})`}</code>
        </pre>
      </div>
    </header>
  );
}

export default function Home(): ReactNode {
  const {siteConfig} = useDocusaurusContext();

  return (
    <Layout
      title={`${siteConfig.title} Documentation`}
      description="Detailed documentation for Rivet, a Roblox/Luau systems layer for managed ModuleScript Units, lifecycle, networking, contracts, codecs, cleanup, plugins, and benchmarks.">
      <HomepageHeader />
      <main>
        <section className={styles.featureBand}>
          <div className="container">
            <div className={styles.featureGrid}>
              <Link className={styles.feature} to="/docs/getting-started/first-unit">
                <strong>Managed Units</strong>
                <span>
                  Put top-level systems in ordinary ModuleScripts and let Rivet
                  handle boot order, lookup, lifecycle, and teardown.
                </span>
              </Link>
              <Link className={styles.feature} to="/docs/core/networking">
                <strong>Explicit Networking</strong>
                <span>
                  Expose only declared Query, Action, and Signal surfaces through
                  generated Roblox remotes.
                </span>
              </Link>
              <Link className={styles.feature} to="/docs/core/contracts">
                <strong>Contracts and Codecs</strong>
                <span>
                  Validate runtime traffic and serialize custom game objects with
                  named encoder/decoder pairs.
                </span>
              </Link>
              <Link className={styles.feature} to="/docs/benchmarks">
                <strong>Benchmarked Runtime</strong>
                <span>
                  Read measured framework overhead and live remote results, then
                  test it yourself when your project needs its own numbers.
                </span>
              </Link>
            </div>
          </div>
        </section>
      </main>
    </Layout>
  );
}
