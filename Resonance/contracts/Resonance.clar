;; Resonance - Decentralized Music Collaboration and Rights Management Platform
;; A comprehensive system for music creation, collaboration, royalty distribution, and IP management

;; Constants - Error codes
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u2000))
(define-constant ERR_TRACK_NOT_FOUND (err u2001))
(define-constant ERR_ALBUM_NOT_FOUND (err u2002))
(define-constant ERR_ARTIST_NOT_FOUND (err u2003))
(define-constant ERR_INVALID_PARAMETERS (err u2004))
(define-constant ERR_INSUFFICIENT_FUNDS (err u2005))
(define-constant ERR_INVALID_ROYALTY_SPLIT (err u2006))
(define-constant ERR_TRACK_ALREADY_EXISTS (err u2007))
(define-constant ERR_NOT_COLLABORATOR (err u2008))
(define-constant ERR_RIGHTS_LOCKED (err u2009))
(define-constant ERR_INVALID_LICENSE (err u2010))
(define-constant ERR_COLLABORATION_CLOSED (err u2011))
(define-constant ERR_MINIMUM_STAKE_NOT_MET (err u2012))

;; Constants - License types
(define-constant LICENSE_EXCLUSIVE u0)
(define-constant LICENSE_NON_EXCLUSIVE u1)
(define-constant LICENSE_CREATIVE_COMMONS u2)
(define-constant LICENSE_COMMERCIAL u3)

;; Constants - Track status
(define-constant STATUS_DRAFT u0)
(define-constant STATUS_COLLABORATION u1)
(define-constant STATUS_REVIEW u2)
(define-constant STATUS_PUBLISHED u3)
(define-constant STATUS_ARCHIVED u4)

;; Constants - Collaboration roles
(define-constant ROLE_COMPOSER u0)
(define-constant ROLE_PRODUCER u1)
(define-constant ROLE_VOCALIST u2)
(define-constant ROLE_INSTRUMENTALIST u3)
(define-constant ROLE_ENGINEER u4)
(define-constant ROLE_SONGWRITER u5)

;; Constants - Revenue streams
(define-constant STREAM_PLATFORM_ROYALTIES u0)
(define-constant STREAM_SYNC_LICENSING u1)
(define-constant STREAM_PERFORMANCE_RIGHTS u2)
(define-constant STREAM_MERCHANDISE u3)
(define-constant STREAM_LIVE_PERFORMANCE u4)

;; Data variables
(define-data-var next-track-id uint u1)
(define-data-var next-album-id uint u1)
(define-data-var next-collaboration-id uint u1)
(define-data-var next-license-id uint u1)
(define-data-var platform-fee-rate uint u500) ;; 5% in basis points
(define-data-var minimum-stake uint u1000000) ;; 1 STX minimum stake
(define-data-var royalty-pool uint u0)
(define-data-var total-tracks-created uint u0)
(define-data-var verification-threshold uint u3) ;; Minimum verifiers needed

;; Core data structures
(define-map tracks
    { track-id: uint }
    {
        title: (string-utf8 256),
        artist: principal,
        album-id: (optional uint),
        duration: uint,
        genre: (string-utf8 64),
        release-date: uint,
        created-at: uint,
        status: uint,
        total-streams: uint,
        total-revenue: uint,
        ipfs-hash: (string-ascii 64),
        metadata-uri: (string-utf8 512),
        is-collaborative: bool,
        rights-locked: bool,
        master-recording-owner: principal
    }
)

(define-map albums
    { album-id: uint }
    {
        title: (string-utf8 256),
        artist: principal,
        total-tracks: uint,
        release-date: uint,
        created-at: uint,
        cover-art-uri: (string-utf8 512),
        description: (string-utf8 1024),
        genre: (string-utf8 64),
        total-revenue: uint,
        is-published: bool
    }
)

(define-map artists
    { artist: principal }
    {
        stage-name: (string-utf8 128),
        bio: (string-utf8 1024),
        website: (string-utf8 256),
        social-links: (list 5 (string-utf8 128)),
        verified: bool,
        reputation-score: uint,
        total-tracks: uint,
        total-collaborations: uint,
        total-earnings: uint,
        joined-at: uint,
        specialty-roles: (list 6 uint)
    }
)

(define-map collaborations
    { collaboration-id: uint }
    {
        track-id: uint,
        initiator: principal,
        created-at: uint,
        deadline: (optional uint),
        max-collaborators: uint,
        current-collaborators: uint,
        minimum-contribution: uint,
        is-open: bool,
        requires-approval: bool,
        collaboration-fund: uint
    }
)

(define-map collaboration-participants
    { collaboration-id: uint, participant: principal }
    {
        role: uint,
        contribution-percentage: uint,
        stake-amount: uint,
        joined-at: uint,
        contribution-description: (string-utf8 512),
        approved: bool,
        work-submitted: bool,
        royalty-share: uint
    }
)

(define-map royalty-splits
    { track-id: uint, beneficiary: principal }
    {
        percentage: uint,
        role: uint,
        locked: bool,
        total-earned: uint,
        last-payout: uint,
        payment-address: principal
    }
)

(define-map licensing-agreements
    { license-id: uint }
    {
        track-id: uint,
        licensee: principal,
        licensor: principal,
        license-type: uint,
        territory: (string-utf8 128),
        duration-start: uint,
        duration-end: uint,
        fee: uint,
        royalty-rate: uint,
        usage-terms: (string-utf8 1024),
        is-active: bool,
        created-at: uint
    }
)

(define-map revenue-tracking
    { track-id: uint, stream-type: uint, period: uint }
    {
        revenue-amount: uint,
        stream-count: uint,
        territory: (string-utf8 64),
        platform: (string-utf8 128),
        period-start: uint,
        period-end: uint,
        verified: bool,
        reported-by: principal
    }
)

(define-map music-rights
    { track-id: uint }
    {
        composition-rights: principal,
        master-recording-rights: principal,
        publishing-rights: principal,
        sync-rights: principal,
        performance-rights: principal,
        mechanical-rights: principal,
        rights-administrator: principal,
        copyright-year: uint
    }
)

(define-map collaboration-history
    { track-id: uint, version: uint }
    {
        contributor: principal,
        timestamp: uint,
        changes-description: (string-utf8 512),
        ipfs-hash: (string-ascii 64),
        approved-by: (list 10 principal),
        version-notes: (string-utf8 256)
    }
)

(define-map artist-reputation
    { artist: principal, evaluator: principal }
    {
        score: uint,
        collaboration-id: (optional uint),
        feedback: (string-utf8 512),
        categories: (list 5 uint), ;; Technical, creativity, professionalism, communication, timeliness
        timestamp: uint
    }
)

;; Read-only functions
(define-read-only (get-track (track-id uint))
    (map-get? tracks { track-id: track-id })
)

(define-read-only (get-album (album-id uint))
    (map-get? albums { album-id: album-id })
)

(define-read-only (get-artist (artist principal))
    (map-get? artists { artist: artist })
)

(define-read-only (get-collaboration (collaboration-id uint))
    (map-get? collaborations { collaboration-id: collaboration-id })
)

(define-read-only (get-royalty-split (track-id uint) (beneficiary principal))
    (map-get? royalty-splits { track-id: track-id, beneficiary: beneficiary })
)

(define-read-only (get-platform-stats)
    {
        total-tracks: (var-get total-tracks-created),
        total-collaborations: (- (var-get next-collaboration-id) u1),
        total-artists: (- (var-get next-track-id) u1),
        royalty-pool: (var-get royalty-pool),
        platform-fee-rate: (var-get platform-fee-rate)
    }
)

(define-read-only (calculate-artist-earnings (artist principal))
    (match (get-artist artist)
        artist-data (ok (get total-earnings artist-data))
        ERR_ARTIST_NOT_FOUND
    )
)

(define-read-only (get-track-revenue (track-id uint))
    (match (get-track track-id)
        track-data
        (ok {
            total-revenue: (get total-revenue track-data),
            total-streams: (get total-streams track-data),
            revenue-per-stream: (if (> (get total-streams track-data) u0)
                                   (/ (get total-revenue track-data) (get total-streams track-data))
                                   u0)
        })
        ERR_TRACK_NOT_FOUND
    )
)

(define-read-only (calculate-royalty-payout (track-id uint) (beneficiary principal))
    (match (get-royalty-split track-id beneficiary)
        split-data
        (match (get-track track-id)
            track-data
            (let (
                (pending-revenue (get total-revenue track-data))
                (beneficiary-share (/ (* pending-revenue (get percentage split-data)) u10000))
                (already-paid (get total-earned split-data))
            )
                (ok (if (> beneficiary-share already-paid)
                      (- beneficiary-share already-paid)
                      u0))
            )
            ERR_TRACK_NOT_FOUND
        )
        (ok u0)
    )
)

(define-read-only (get-collaboration-details (collaboration-id uint))
    (match (get-collaboration collaboration-id)
        collab-data
        (match (get-track (get track-id collab-data))
            track-data
            (ok {
                track-title: (get title track-data),
                initiator: (get initiator collab-data),
                current-collaborators: (get current-collaborators collab-data),
                max-collaborators: (get max-collaborators collab-data),
                collaboration-fund: (get collaboration-fund collab-data),
                is-open: (get is-open collab-data),
                track-status: (get status track-data)
            })
            ERR_TRACK_NOT_FOUND
        )
        ERR_COLLABORATION_CLOSED
    )
)

(define-read-only (validate-royalty-splits (track-id uint))
    (let (
        ;; This would typically iterate through all splits for a track
        ;; For demonstration, we'll return a basic validation
        (total-percentage u10000) ;; Placeholder - would calculate actual total
    )
        (ok (is-eq total-percentage u10000))
    )
)

;; Private helper functions
(define-private (is-track-collaborator (track-id uint) (user principal))
    (match (get-track track-id)
        track-data
        (if (get is-collaborative track-data)
            ;; Check if user is in any collaboration for this track
            true ;; Simplified - would check collaboration-participants map
            (is-eq user (get artist track-data))
        )
        false
    )
)

(define-private (calculate-reputation-bonus (artist principal))
    (match (get-artist artist)
        artist-data
        (let (
            (rep-score (get reputation-score artist-data))
        )
            (if (>= rep-score u1000)
                u110 ;; 10% bonus for high reputation
                (if (>= rep-score u500)
                    u105 ;; 5% bonus for medium reputation
                    u100 ;; No bonus for low reputation
                )
            )
        )
        u100
    )
)

(define-private (distribute-platform-fee (amount uint))
    (let (
        (platform-fee (/ (* amount (var-get platform-fee-rate)) u10000))
        (to-royalty-pool (/ (* platform-fee u60) u100)) ;; 60% to royalty pool
        (to-owner (- platform-fee to-royalty-pool)) ;; 40% to contract owner
    )
        (var-set royalty-pool (+ (var-get royalty-pool) to-royalty-pool))
        ;; Transfer owner portion would happen here
        platform-fee
    )
)

(define-private (update-artist-reputation (artist principal) (reputation-change int))
    (match (get-artist artist)
        artist-data
        (let (
            (current-rep (to-int (get reputation-score artist-data)))
            (new-rep-int (+ current-rep reputation-change))
            (new-rep (to-uint (if (>= new-rep-int 0) new-rep-int 0)))
        )
            (map-set artists
                { artist: artist }
                (merge artist-data { reputation-score: new-rep })
            )
            true
        )
        false
    )
)

;; Public functions

;; Artist Management
(define-public (register-artist 
    (stage-name (string-utf8 128))
    (bio (string-utf8 1024))
    (website (string-utf8 256))
    (social-links (list 5 (string-utf8 128)))
    (specialty-roles (list 6 uint))
)
    (begin
        (asserts! (> (len stage-name) u0) ERR_INVALID_PARAMETERS)
        (asserts! (is-none (get-artist tx-sender)) ERR_TRACK_ALREADY_EXISTS)
        
        (map-set artists
            { artist: tx-sender }
            {
                stage-name: stage-name,
                bio: bio,
                website: website,
                social-links: social-links,
                verified: false,
                reputation-score: u500, ;; Starting reputation
                total-tracks: u0,
                total-collaborations: u0,
                total-earnings: u0,
                joined-at: stacks-block-height,
                specialty-roles: specialty-roles
            }
        )
        (ok true)
    )
)

;; Track Management
(define-public (create-track
    (title (string-utf8 256))
    (album-id (optional uint))
    (duration uint)
    (genre (string-utf8 64))
    (ipfs-hash (string-ascii 64))
    (metadata-uri (string-utf8 512))
    (is-collaborative bool)
)
    (let (
        (track-id (var-get next-track-id))
    )
        (asserts! (> (len title) u0) ERR_INVALID_PARAMETERS)
        (asserts! (> duration u0) ERR_INVALID_PARAMETERS)
        (asserts! (is-some (get-artist tx-sender)) ERR_ARTIST_NOT_FOUND)
        
        ;; Verify album exists if specified
        (match album-id
            album-id-val
            (asserts! (is-some (get-album album-id-val)) ERR_ALBUM_NOT_FOUND)
            true
        )
        
        ;; Create track
        (map-set tracks
            { track-id: track-id }
            {
                title: title,
                artist: tx-sender,
                album-id: album-id,
                duration: duration,
                genre: genre,
                release-date: u0,
                created-at: stacks-block-height,
                status: STATUS_DRAFT,
                total-streams: u0,
                total-revenue: u0,
                ipfs-hash: ipfs-hash,
                metadata-uri: metadata-uri,
                is-collaborative: is-collaborative,
                rights-locked: false,
                master-recording-owner: tx-sender
            }
        )
        
        ;; Initialize rights
        (map-set music-rights
            { track-id: track-id }
            {
                composition-rights: tx-sender,
                master-recording-rights: tx-sender,
                publishing-rights: tx-sender,
                sync-rights: tx-sender,
                performance-rights: tx-sender,
                mechanical-rights: tx-sender,
                rights-administrator: tx-sender,
                copyright-year: (/ stacks-block-height u52560) ;; Approximate year
            }
        )
        
        ;; Set initial royalty split (100% to creator)
        (map-set royalty-splits
            { track-id: track-id, beneficiary: tx-sender }
            {
                percentage: u10000, ;; 100%
                role: ROLE_COMPOSER,
                locked: false,
                total-earned: u0,
                last-payout: u0,
                payment-address: tx-sender
            }
        )
        
        ;; Update artist stats
        (match (get-artist tx-sender)
            artist-data
            (map-set artists
                { artist: tx-sender }
                (merge artist-data { total-tracks: (+ (get total-tracks artist-data) u1) })
            )
            false
        )
        
        (var-set next-track-id (+ track-id u1))
        (var-set total-tracks-created (+ (var-get total-tracks-created) u1))
        (ok track-id)
    )
)

;; Collaboration Management
(define-public (initiate-collaboration
    (track-id uint)
    (max-collaborators uint)
    (minimum-contribution uint)
    (deadline (optional uint))
    (requires-approval bool)
)
    (let (
        (collaboration-id (var-get next-collaboration-id))
        (track-data (unwrap! (get-track track-id) ERR_TRACK_NOT_FOUND))
    )
        (asserts! (is-eq tx-sender (get artist track-data)) ERR_UNAUTHORIZED)
        (asserts! (get is-collaborative track-data) ERR_INVALID_PARAMETERS)
        (asserts! (not (get rights-locked track-data)) ERR_RIGHTS_LOCKED)
        (asserts! (> max-collaborators u0) ERR_INVALID_PARAMETERS)
        (asserts! (<= max-collaborators u50) ERR_INVALID_PARAMETERS)
        
        ;; Verify deadline if provided
        (match deadline
            deadline-val
            (asserts! (> deadline-val stacks-block-height) ERR_INVALID_PARAMETERS)
            true
        )
        
        (map-set collaborations
            { collaboration-id: collaboration-id }
            {
                track-id: track-id,
                initiator: tx-sender,
                created-at: stacks-block-height,
                deadline: deadline,
                max-collaborators: max-collaborators,
                current-collaborators: u1,
                minimum-contribution: minimum-contribution,
                is-open: true,
                requires-approval: requires-approval,
                collaboration-fund: u0
            }
        )
        
        ;; Add initiator as first participant
        (map-set collaboration-participants
            { collaboration-id: collaboration-id, participant: tx-sender }
            {
                role: ROLE_COMPOSER,
                contribution-percentage: u0, ;; Will be set when collaboration completes
                stake-amount: u0,
                joined-at: stacks-block-height,
                contribution-description: u"Original creator",
                approved: true,
                work-submitted: false,
                royalty-share: u0 ;; Will be determined later
            }
        )
        
        ;; Update track status
        (map-set tracks
            { track-id: track-id }
            (merge track-data { status: STATUS_COLLABORATION })
        )
        
        (var-set next-collaboration-id (+ collaboration-id u1))
        (ok collaboration-id)
    )
)

(define-public (join-collaboration
    (collaboration-id uint)
    (role uint)
    (contribution-description (string-utf8 512))
    (stake-amount uint)
)
    (let (
        (collab-data (unwrap! (get-collaboration collaboration-id) ERR_COLLABORATION_CLOSED))
        (track-data (unwrap! (get-track (get track-id collab-data)) ERR_TRACK_NOT_FOUND))
    )
        (asserts! (get is-open collab-data) ERR_COLLABORATION_CLOSED)
        (asserts! (< (get current-collaborators collab-data) (get max-collaborators collab-data)) ERR_COLLABORATION_CLOSED)
        (asserts! (>= stake-amount (get minimum-contribution collab-data)) ERR_MINIMUM_STAKE_NOT_MET)
        (asserts! (<= role ROLE_SONGWRITER) ERR_INVALID_PARAMETERS)
        (asserts! (is-some (get-artist tx-sender)) ERR_ARTIST_NOT_FOUND)
        
        ;; Check if deadline has passed
        (match (get deadline collab-data)
            deadline-val
            (asserts! (< stacks-block-height deadline-val) ERR_COLLABORATION_CLOSED)
            true
        )
        
        ;; Transfer stake to collaboration fund
        (if (> stake-amount u0)
            (try! (stx-transfer? stake-amount tx-sender (as-contract tx-sender)))
            true
        )
        
        ;; Add participant
        (map-set collaboration-participants
            { collaboration-id: collaboration-id, participant: tx-sender }
            {
                role: role,
                contribution-percentage: u0,
                stake-amount: stake-amount,
                joined-at: stacks-block-height,
                contribution-description: contribution-description,
                approved: (not (get requires-approval collab-data)),
                work-submitted: false,
                royalty-share: u0
            }
        )
        
        ;; Update collaboration stats
        (map-set collaborations
            { collaboration-id: collaboration-id }
            (merge collab-data {
                current-collaborators: (+ (get current-collaborators collab-data) u1),
                collaboration-fund: (+ (get collaboration-fund collab-data) stake-amount)
            })
        )
        
        ;; Update artist collaboration count
        (match (get-artist tx-sender)
            artist-data
            (map-set artists
                { artist: tx-sender }
                (merge artist-data { 
                    total-collaborations: (+ (get total-collaborations artist-data) u1)
                })
            )
            false
        )
        
        (ok true)
    )
)

;; Revenue and Royalty Management
(define-public (report-revenue
    (track-id uint)
    (stream-type uint)
    (revenue-amount uint)
    (stream-count uint)
    (territory (string-utf8 64))
    (platform (string-utf8 128))
    (period uint)
)
    (let (
        (track-data (unwrap! (get-track track-id) ERR_TRACK_NOT_FOUND))
    )
        (asserts! (is-track-collaborator track-id tx-sender) ERR_NOT_COLLABORATOR)
        (asserts! (> revenue-amount u0) ERR_INVALID_PARAMETERS)
        (asserts! (<= stream-type STREAM_LIVE_PERFORMANCE) ERR_INVALID_PARAMETERS)
        
        ;; Record revenue
        (map-set revenue-tracking
            { track-id: track-id, stream-type: stream-type, period: period }
            {
                revenue-amount: revenue-amount,
                stream-count: stream-count,
                territory: territory,
                platform: platform,
                period-start: stacks-block-height,
                period-end: (+ stacks-block-height u4032), ;; ~1 month
                verified: false,
                reported-by: tx-sender
            }
        )
        
        ;; Update track totals
        (map-set tracks
            { track-id: track-id }
            (merge track-data {
                total-revenue: (+ (get total-revenue track-data) revenue-amount),
                total-streams: (+ (get total-streams track-data) stream-count)
            })
        )
        
        (ok true)
    )
)

(define-public (distribute-royalties (track-id uint) (beneficiary principal))
    (let (
        (track-data (unwrap! (get-track track-id) ERR_TRACK_NOT_FOUND))
        (split-data (unwrap! (get-royalty-split track-id beneficiary) ERR_UNAUTHORIZED))
        (payout-amount (unwrap! (calculate-royalty-payout track-id beneficiary) ERR_INVALID_PARAMETERS))
    )
        (asserts! (> payout-amount u0) ERR_INSUFFICIENT_FUNDS)
        (asserts! (not (get locked split-data)) ERR_RIGHTS_LOCKED)
        
        ;; Calculate platform fee
        (let (
            (platform-fee (distribute-platform-fee payout-amount))
            (net-payout (- payout-amount platform-fee))
            (reputation-bonus (calculate-reputation-bonus beneficiary))
            (final-payout (/ (* net-payout reputation-bonus) u100))
        )
            ;; Transfer payout
            (try! (as-contract (stx-transfer? final-payout tx-sender (get payment-address split-data))))
            
            ;; Update split record
            (map-set royalty-splits
                { track-id: track-id, beneficiary: beneficiary }
                (merge split-data {
                    total-earned: (+ (get total-earned split-data) final-payout),
                    last-payout: stacks-block-height
                })
            )
            
            ;; Update artist earnings
            (match (get-artist beneficiary)
                artist-data
                (map-set artists
                    { artist: beneficiary }
                    (merge artist-data { 
                        total-earnings: (+ (get total-earnings artist-data) final-payout)
                    })
                )
                false
            )
            
            (ok final-payout)
        )
    )
)

;; Rights Management
(define-public (update-royalty-split
    (track-id uint)
    (beneficiary principal)
    (new-percentage uint)
    (role uint)
)
    (let (
        (track-data (unwrap! (get-track track-id) ERR_TRACK_NOT_FOUND))
        (existing-split (get-royalty-split track-id beneficiary))
    )
        (asserts! (is-track-collaborator track-id tx-sender) ERR_NOT_COLLABORATOR)
        (asserts! (not (get rights-locked track-data)) ERR_RIGHTS_LOCKED)
        (asserts! (<= new-percentage u10000) ERR_INVALID_ROYALTY_SPLIT)
        (asserts! (<= role ROLE_SONGWRITER) ERR_INVALID_PARAMETERS)
        
        (match existing-split
            split-data
            (asserts! (not (get locked split-data)) ERR_RIGHTS_LOCKED)
            true
        )
        
        ;; Update or create royalty split
        (map-set royalty-splits
            { track-id: track-id, beneficiary: beneficiary }
            {
                percentage: new-percentage,
                role: role,
                locked: false,
                total-earned: (match existing-split
                              split-data (get total-earned split-data)
                              u0),
                last-payout: (match existing-split
                             split-data (get last-payout split-data)
                             u0),
                payment-address: beneficiary
            }
        )
        
        (ok true)
    )
)

(define-public (lock-rights (track-id uint))
    (let (
        (track-data (unwrap! (get-track track-id) ERR_TRACK_NOT_FOUND))
    )
        (asserts! (is-eq tx-sender (get artist track-data)) ERR_UNAUTHORIZED)
        (asserts! (not (get rights-locked track-data)) ERR_RIGHTS_LOCKED)
        
        ;; Verify splits total 100%
        (asserts! (unwrap! (validate-royalty-splits track-id) ERR_INVALID_ROYALTY_SPLIT) ERR_INVALID_ROYALTY_SPLIT)
        
        ;; Lock the track rights
        (map-set tracks
            { track-id: track-id }
            (merge track-data { rights-locked: true })
        )
        
        (ok true)
    )
)

;; Licensing
(define-public (create-license
    (track-id uint)
    (licensee principal)
    (license-type uint)
    (territory (string-utf8 128))
    (duration-months uint)
    (fee uint)
    (royalty-rate uint)
    (usage-terms (string-utf8 1024))
)
    (let (
        (track-data (unwrap! (get-track track-id) ERR_TRACK_NOT_FOUND))
        (license-id (var-get next-license-id))
    )
        (asserts! (is-track-collaborator track-id tx-sender) ERR_NOT_COLLABORATOR)
        (asserts! (<= license-type LICENSE_COMMERCIAL) ERR_INVALID_LICENSE)
        (asserts! (> duration-months u0) ERR_INVALID_PARAMETERS)
        (asserts! (<= royalty-rate u10000) ERR_INVALID_PARAMETERS)
        
        ;; Transfer licensing fee
        (if (> fee u0)
            (try! (stx-transfer? fee licensee (as-contract tx-sender)))
            true
        )
        
        (map-set licensing-agreements
            { license-id: license-id }
            {
                track-id: track-id,
                licensee: licensee,
                licensor: tx-sender,
                license-type: license-type,
                territory: territory,
                duration-start: stacks-block-height,
                duration-end: (+ stacks-block-height (* duration-months u4032)),
                fee: fee,
                royalty-rate: royalty-rate,
                usage-terms: usage-terms,
                is-active: true,
                created-at: stacks-block-height
            }
        )
        
        (var-set next-license-id (+ license-id u1))
        (ok license-id)
    )
)

;; Album Management
(define-public (create-album
    (title (string-utf8 256))
    (cover-art-uri (string-utf8 512))
    (description (string-utf8 1024))
    (genre (string-utf8 64))
    (release-date uint)
)
    (let (
        (album-id (var-get next-album-id))
    )
        (asserts! (> (len title) u0) ERR_INVALID_PARAMETERS)
        (asserts! (is-some (get-artist tx-sender)) ERR_ARTIST_NOT_FOUND)
        (asserts! (> release-date stacks-block-height) ERR_INVALID_PARAMETERS)
        
        (map-set albums
            { album-id: album-id }
            {
                title: title,
                artist: tx-sender,
                total-tracks: u0,
                release-date: release-date,
                created-at: stacks-block-height,
                cover-art-uri: cover-art-uri,
                description: description,
                genre: genre,
                total-revenue: u0,
                is-published: false
            }
        )
        
        (var-set next-album-id (+ album-id u1))
        (ok album-id)
    )
)

(define-public (add-track-to-album (track-id uint) (album-id uint))
    (let (
        (track-data (unwrap! (get-track track-id) ERR_TRACK_NOT_FOUND))
        (album-data (unwrap! (get-album album-id) ERR_ALBUM_NOT_FOUND))
    )
        (asserts! (is-eq tx-sender (get artist track-data)) ERR_UNAUTHORIZED)
        (asserts! (is-eq tx-sender (get artist album-data)) ERR_UNAUTHORIZED)
        (asserts! (is-none (get album-id track-data)) ERR_INVALID_PARAMETERS)
        
        ;; Update track with album reference
        (map-set tracks
            { track-id: track-id }
            (merge track-data { album-id: (some album-id) })
        )
        
        ;; Update album track count
        (map-set albums
            { album-id: album-id }
            (merge album-data { total-tracks: (+ (get total-tracks album-data) u1) })
        )
        
        (ok true)
    )
)

;; Collaboration Workflow
(define-public (submit-collaboration-work
    (collaboration-id uint)
    (work-description (string-utf8 512))
    (ipfs-hash (string-ascii 64))
)
    (let (
        (collab-data (unwrap! (get-collaboration collaboration-id) ERR_COLLABORATION_CLOSED))
        (participant-data (unwrap! (map-get? collaboration-participants 
                                           { collaboration-id: collaboration-id, participant: tx-sender })
                                  ERR_NOT_COLLABORATOR))
    )
        (asserts! (get approved participant-data) ERR_UNAUTHORIZED)
        (asserts! (get is-open collab-data) ERR_COLLABORATION_CLOSED)
        
        ;; Update participant work submission
        (map-set collaboration-participants
            { collaboration-id: collaboration-id, participant: tx-sender }
            (merge participant-data {
                work-submitted: true,
                contribution-description: work-description
            })
        )
        
        ;; Record version history
        (let (
            (track-id (get track-id collab-data))
            (version-count u1) ;; Would typically calculate actual version number
        )
            (map-set collaboration-history
                { track-id: track-id, version: version-count }
                {
                    contributor: tx-sender,
                    timestamp: stacks-block-height,
                    changes-description: work-description,
                    ipfs-hash: ipfs-hash,
                    approved-by: (list),
                    version-notes: u"Work submission"
                }
            )
        )
        
        (ok true)
    )
)

(define-public (approve-collaboration-participant
    (collaboration-id uint)
    (participant principal)
)
    (let (
        (collab-data (unwrap! (get-collaboration collaboration-id) ERR_COLLABORATION_CLOSED))
        (participant-data (unwrap! (map-get? collaboration-participants 
                                           { collaboration-id: collaboration-id, participant: participant })
                                  ERR_NOT_COLLABORATOR))
    )
        (asserts! (is-eq tx-sender (get initiator collab-data)) ERR_UNAUTHORIZED)
        (asserts! (get requires-approval collab-data) ERR_INVALID_PARAMETERS)
        (asserts! (not (get approved participant-data)) ERR_INVALID_PARAMETERS)
        
        ;; Approve participant
        (map-set collaboration-participants
            { collaboration-id: collaboration-id, participant: participant }
            (merge participant-data { approved: true })
        )
        
        ;; Update participant's reputation
        (update-artist-reputation participant 25)
        
        (ok true)
    )
)

(define-public (finalize-collaboration (collaboration-id uint))
    (let (
        (collab-data (unwrap! (get-collaboration collaboration-id) ERR_COLLABORATION_CLOSED))
        (track-data (unwrap! (get-track (get track-id collab-data)) ERR_TRACK_NOT_FOUND))
    )
        (asserts! (is-eq tx-sender (get initiator collab-data)) ERR_UNAUTHORIZED)
        (asserts! (get is-open collab-data) ERR_COLLABORATION_CLOSED)
        
        ;; Close collaboration
        (map-set collaborations
            { collaboration-id: collaboration-id }
            (merge collab-data { is-open: false })
        )
        
        ;; Update track status
        (map-set tracks
            { track-id: (get track-id collab-data) }
            (merge track-data { status: STATUS_REVIEW })
        )
        
        ;; Distribute collaboration fund based on contributions
        (let (
            (fund-amount (get collaboration-fund collab-data))
            (platform-fee (distribute-platform-fee fund-amount))
            (distributable-amount (- fund-amount platform-fee))
        )
            ;; Would implement actual distribution logic here
            (ok distributable-amount)
        )
    )
)

;; Quality Control and Verification
(define-public (verify-artist (artist principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (is-some (get-artist artist)) ERR_ARTIST_NOT_FOUND)
        
        (match (get-artist artist)
            artist-data
            (map-set artists
                { artist: artist }
                (merge artist-data { verified: true })
            )
            false
        )
        
        ;; Boost reputation for verified artists
        (update-artist-reputation artist 200)
        (ok true)
    )
)

(define-public (rate-collaboration
    (collaboration-id uint)
    (rated-artist principal)
    (technical-score uint)
    (creativity-score uint)
    (professionalism-score uint)
    (communication-score uint)
    (timeliness-score uint)
    (feedback (string-utf8 512))
)
    (let (
        (collab-data (unwrap! (get-collaboration collaboration-id) ERR_COLLABORATION_CLOSED))
        (participant-data (unwrap! (map-get? collaboration-participants 
                                           { collaboration-id: collaboration-id, participant: tx-sender })
                                  ERR_NOT_COLLABORATOR))
        (rated-participant (unwrap! (map-get? collaboration-participants 
                                            { collaboration-id: collaboration-id, participant: rated-artist })
                                   ERR_NOT_COLLABORATOR))
    )
        (asserts! (not (get is-open collab-data)) ERR_COLLABORATION_CLOSED)
        (asserts! (get approved participant-data) ERR_UNAUTHORIZED)
        (asserts! (get approved rated-participant) ERR_UNAUTHORIZED)
        (asserts! (not (is-eq tx-sender rated-artist)) ERR_INVALID_PARAMETERS)
        
        ;; Validate scores (1-10 scale)
        (asserts! (and (<= technical-score u10) (>= technical-score u1)) ERR_INVALID_PARAMETERS)
        (asserts! (and (<= creativity-score u10) (>= creativity-score u1)) ERR_INVALID_PARAMETERS)
        (asserts! (and (<= professionalism-score u10) (>= professionalism-score u1)) ERR_INVALID_PARAMETERS)
        (asserts! (and (<= communication-score u10) (>= communication-score u1)) ERR_INVALID_PARAMETERS)
        (asserts! (and (<= timeliness-score u10) (>= timeliness-score u1)) ERR_INVALID_PARAMETERS)
        
        (let (
            (average-score (/ (+ technical-score creativity-score professionalism-score 
                                communication-score timeliness-score) u5))
            (event-id (+ collaboration-id stacks-block-height)) ;; Simple event ID generation
        )
            ;; Record rating
            (map-set artist-reputation
                { artist: rated-artist, evaluator: tx-sender }
                {
                    score: average-score,
                    collaboration-id: (some collaboration-id),
                    feedback: feedback,
                    categories: (list technical-score creativity-score professionalism-score 
                                     communication-score timeliness-score),
                    timestamp: stacks-block-height
                }
            )
            
            ;; Update artist's overall reputation
            (let (
                (reputation-change (to-int (if (>= average-score u7) 
                                             (* (- average-score u5) u10) ;; Positive change
                                             (* (- average-score u5) u5))))  ;; Negative change
            )
                (update-artist-reputation rated-artist reputation-change)
            )
            
            (ok average-score)
        )
    )
)

;; Publishing and Release Management
(define-public (publish-track (track-id uint))
    (let (
        (track-data (unwrap! (get-track track-id) ERR_TRACK_NOT_FOUND))
    )
        (asserts! (is-eq tx-sender (get artist track-data)) ERR_UNAUTHORIZED)
        (asserts! (or (is-eq (get status track-data) STATUS_REVIEW)
                      (is-eq (get status track-data) STATUS_DRAFT)) ERR_INVALID_PARAMETERS)
        (asserts! (get rights-locked track-data) ERR_RIGHTS_LOCKED)
        
        ;; Update track status and release date
        (map-set tracks
            { track-id: track-id }
            (merge track-data {
                status: STATUS_PUBLISHED,
                release-date: stacks-block-height
            })
        )
        
        ;; Update artist reputation for publishing
        (update-artist-reputation tx-sender 50)
        
        (ok true)
    )
)

(define-public (publish-album (album-id uint))
    (let (
        (album-data (unwrap! (get-album album-id) ERR_ALBUM_NOT_FOUND))
    )
        (asserts! (is-eq tx-sender (get artist album-data)) ERR_UNAUTHORIZED)
        (asserts! (not (get is-published album-data)) ERR_INVALID_PARAMETERS)
        (asserts! (> (get total-tracks album-data) u0) ERR_INVALID_PARAMETERS)
        
        (map-set albums
            { album-id: album-id }
            (merge album-data { is-published: true })
        )
        
        (ok true)
    )
)

;; Platform Administration
(define-public (update-platform-settings
    (new-fee-rate uint)
    (new-minimum-stake uint)
    (new-verification-threshold uint)
)
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (<= new-fee-rate u2000) ERR_INVALID_PARAMETERS) ;; Max 20%
        (asserts! (>= new-minimum-stake u100000) ERR_INVALID_PARAMETERS) ;; Min 0.1 STX
        (asserts! (<= new-verification-threshold u10) ERR_INVALID_PARAMETERS)
        
        (var-set platform-fee-rate new-fee-rate)
        (var-set minimum-stake new-minimum-stake)
        (var-set verification-threshold new-verification-threshold)
        
        (ok true)
    )
)

(define-public (emergency-pause-track (track-id uint))
    (let (
        (track-data (unwrap! (get-track track-id) ERR_TRACK_NOT_FOUND))
    )
        (asserts! (or (is-eq tx-sender CONTRACT_OWNER)
                      (is-eq tx-sender (get artist track-data))) ERR_UNAUTHORIZED)
        
        (map-set tracks
            { track-id: track-id }
            (merge track-data { status: STATUS_ARCHIVED })
        )
        
        (ok true)
    )
)

(define-public (withdraw-royalty-pool (amount uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (<= amount (var-get royalty-pool)) ERR_INSUFFICIENT_FUNDS)
        
        (try! (as-contract (stx-transfer? amount tx-sender CONTRACT_OWNER)))
        (var-set royalty-pool (- (var-get royalty-pool) amount))
        
        (ok amount)
    )
)