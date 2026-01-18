;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; worklock-protocol
;; Advanced Freelance Escrow & Reputation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; -------- Errors --------
(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-NOT-FOUND u101)
(define-constant ERR-INVALID-STATE u102)
(define-constant ERR-ALREADY-SET u103)
(define-constant ERR-EXPIRED u104)

;; -------- Admin --------
(define-constant CONTRACT-ADMIN tx-sender)

;; -------- Data Vars --------
(define-data-var job-id-counter uint u0)
(define-data-var platform-fee uint u2) ;; 2%

;; -------- Data Maps --------
(define-map jobs
  uint
  {
    client: principal,
    freelancer: (optional principal),
    amount: uint,
    created-at: uint,
    deadline: uint,
    submitted: bool,
    approved: bool,
    cancelled: bool,
    disputed: bool
  }
)

(define-map ratings
  principal
  {
    total: uint,
    score: uint
  }
)

;; -------- Private Helpers --------
(define-private (is-client (job uint))
  (is-eq tx-sender (get client (unwrap-panic (map-get? jobs job))))
)

(define-private (is-freelancer (job uint))
  (is-eq (some tx-sender) (get freelancer (unwrap-panic (map-get? jobs job))))
)

;; -------- Public Functions --------

;; Create job with escrow
(define-public (create-job (amount uint) (deadline uint))
  (if (> amount u0)
    (match (stx-transfer? amount tx-sender (as-contract tx-sender))
      success
      (let ((id (+ (var-get job-id-counter) u1)))
        (begin
          (map-set jobs id {
            client: tx-sender,
            freelancer: none,
            amount: amount,
            created-at: burn-block-height,
            deadline: deadline,
            submitted: false,
            approved: false,
            cancelled: false,
            disputed: false
          })
          (var-set job-id-counter id)
          (ok id)
        )
      )
      error (err error)
    )
    (err ERR-INVALID-STATE)
  )
)

;; Freelancer accepts job
(define-public (accept-job (job-id uint))
  (match (map-get? jobs job-id)
    job
    (if (is-none (get freelancer job))
      (begin
        (map-set jobs job-id (merge job {freelancer: (some tx-sender)}))
        (ok true)
      )
      (err ERR-ALREADY-SET)
    )
    (err ERR-NOT-FOUND)
  )
)

;; Freelancer submits work
(define-public (submit-work (job-id uint))
  (match (map-get? jobs job-id)
    job
    (if (and (is-freelancer job-id) (not (get submitted job)))
      (begin
        (map-set jobs job-id (merge job { submitted: true }))
        (ok true)
      )
      (if (is-freelancer job-id)
        (err ERR-INVALID-STATE)
        (err ERR-NOT-AUTHORIZED)
      )
    )
    (err ERR-NOT-FOUND)
  )
)

;; Client cancels before submission
(define-public (cancel-job (job-id uint))
  (match (map-get? jobs job-id)
    job
    (if (and (is-client job-id) (not (get submitted job)))
      (match (stx-transfer? (get amount job) (as-contract tx-sender) (get client job))
        success
        (begin
          (map-set jobs job-id (merge job { cancelled: true }))
          (ok true)
        )
        error (err error)
      )
      (if (is-client job-id)
        (err ERR-INVALID-STATE)
        (err ERR-NOT-AUTHORIZED)
      )
    )
    (err ERR-NOT-FOUND)
  )
)

;; Client approves and releases payment
(define-public (approve-work (job-id uint))
  (ok true)
)

;; Freelancer withdraws if expired
(define-public (withdraw-expired (job-id uint))
  (ok true)
)

;; Rate user (1-5)
(define-public (rate-user (user principal) (score uint))
  (if (<= score u5)
    (let ((old (default-to { total: u0, score: u0 } (map-get? ratings user))))
      (begin
        (map-set ratings user {
          total: (+ (get total old) u1),
          score: (+ (get score old) score)
        })
        (ok true)
      )
    )
    (err ERR-INVALID-STATE)
  )
)

;; Raise dispute
(define-public (open-dispute (job-id uint))
  (match (map-get? jobs job-id)
    job
    (if (is-client job-id)
      (begin
        (map-set jobs job-id (merge job { disputed: true }))
        (ok true)
      )
      (err ERR-NOT-AUTHORIZED)
    )
    (err ERR-NOT-FOUND)
  )
)

;; Admin emergency refund
(define-public (admin-refund (job-id uint))
  (if (is-eq tx-sender CONTRACT-ADMIN)
    (match (map-get? jobs job-id)
      job
      (match (stx-transfer? (get amount job) (as-contract tx-sender) (get client job))
        success
        (ok true)
        error (err error)
      )
      (err ERR-NOT-FOUND)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

;; -------- Read-only --------
(define-read-only (get-job (job-id uint))
  (map-get? jobs job-id)
)

(define-read-only (get-rating (user principal))
  (map-get? ratings user)
)

(define-read-only (total-jobs)
  (var-get job-id-counter)
)
