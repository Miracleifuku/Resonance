# Resonance – Decentralized Music Collaboration & Rights Management 🎶🎛️

## Description

**Resonance** is a **comprehensive Web3 protocol** for **music creation, collaboration, royalty distribution, licensing, and IP management** on-chain.
It empowers **artists, producers, and collaborators** with tools to **secure ownership, automate royalties, enable licensing, and transparently manage creative partnerships**.

## Installation / Deployment

```sh
clarinet check
clarinet deploy
```

## Features

* **Artist Registry** → On-chain artist profiles with reputation scores & roles
* **Track Management** → Create, publish, archive, and manage music metadata with IPFS integration
* **Collaboration System** → Open, join, contribute, and finalize collaborative music projects
* **Royalty Splits** → Define flexible royalty shares across collaborators and roles
* **Revenue Tracking** → Report & verify revenues from multiple streams (platform, sync, live, merch, etc.)
* **Automated Payouts** → Transparent royalty distribution with reputation-based bonuses
* **Rights Management** → Assign and lock master, publishing, sync, and performance rights
* **Licensing Engine** → Exclusive/non-exclusive licensing agreements with fees & royalties
* **Album Management** → Create albums, add tracks, and manage releases
* **Reputation System** → Collaboration ratings to reward professionalism and creativity

## Usage

### Artist Management

* `register-artist(stage-name, bio, website, social-links, roles)` → Register artist profile
* `get-artist(artist)` → Fetch artist data & reputation

### Tracks

* `create-track(title, album-id, duration, genre, ipfs-hash, metadata-uri, collaborative)`
* `get-track(track-id)` → Track details & rights
* `lock-rights(track-id)` → Finalize and lock royalty splits

### Collaborations

* `initiate-collaboration(track-id, max-collaborators, min-stake, deadline, requires-approval)`
* `join-collaboration(collab-id, role, description, stake)`
* `submit-collaboration-work(collab-id, description, ipfs-hash)`
* `approve-collaboration-participant(collab-id, participant)`
* `finalize-collaboration(collab-id)`

### Royalties & Revenue

* `report-revenue(track-id, stream-type, revenue, streams, territory, platform, period)`
* `distribute-royalties(track-id, beneficiary)` → Trigger royalty payout
* `update-royalty-split(track-id, beneficiary, percentage, role)`

### Licensing

* `create-license(track-id, licensee, type, territory, duration, fee, royalty-rate, terms)`
* License types: **exclusive, non-exclusive, creative commons, commercial**

### Albums

* `create-album(title, cover-art, description, genre, release-date)`
* `add-track-to-album(track-id, album-id)`

### Read-Only Queries

* `get-platform-stats()` → Tracks, artists, collaborations, royalty pool
* `calculate-artist-earnings(artist)` → Total on-chain earnings
* `get-track-revenue(track-id)` → Revenue, streams, revenue per stream
* `calculate-royalty-payout(track-id, beneficiary)` → Pending payout

---

🎼 **Resonance: The decentralized future of music rights, royalties, and collaboration.**
