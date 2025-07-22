;; Disaster Preparedness Coordination Contract
;; Helps communities prepare for and respond to emergencies

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u200))
(define-constant ERR-INVALID-INPUT (err u201))
(define-constant ERR-RESOURCE-NOT-FOUND (err u202))
(define-constant ERR-VOLUNTEER-NOT-FOUND (err u203))
(define-constant ERR-ALREADY-REGISTERED (err u204))
(define-constant ERR-INSUFFICIENT-RESOURCES (err u205))

;; Data Variables
(define-data-var next-resource-id uint u1)
(define-data-var next-volunteer-id uint u1)
(define-data-var emergency-status bool false)
(define-data-var preparedness-level uint u0)

;; Data Maps
(define-map emergency-resources
  uint
  {
    resource-type: (string-ascii 50),
    quantity: uint,
    location: (string-ascii 100),
    owner: principal,
    available: bool,
    last-updated: uint
  }
)

(define-map volunteers
  uint
  {
    volunteer: principal,
    skills: (string-ascii 200),
    experience-level: uint,
    availability: bool,
    contact-info: (string-ascii 100),
    last-active: uint
  }
)

(define-map volunteer-by-principal
  principal
  uint
)

(define-map emergency-plans
  (string-ascii 50)
  {
    plan-type: (string-ascii 50),
    description: (string-ascii 500),
    coordinator: principal,
    status: (string-ascii 20),
    last-updated: uint
  }
)

(define-map resource-requests
  uint
  {
    requester: principal,
    resource-type: (string-ascii 50),
    quantity-needed: uint,
    urgency-level: uint,
    fulfilled: bool,
    timestamp: uint
  }
)

;; Public Functions

;; Register as emergency volunteer
(define-public (register-volunteer (skills (string-ascii 200)) (experience-level uint))
  (let
    (
      (volunteer-id (var-get next-volunteer-id))
      (existing-volunteer (map-get? volunteer-by-principal tx-sender))
    )
    (asserts! (is-none existing-volunteer) ERR-ALREADY-REGISTERED)
    (asserts! (> experience-level u0) ERR-INVALID-INPUT)
    (asserts! (<= experience-level u10) ERR-INVALID-INPUT)

    ;; Register volunteer
    (map-set volunteers volunteer-id
      {
        volunteer: tx-sender,
        skills: skills,
        experience-level: experience-level,
        availability: true,
        contact-info: "",
        last-active: block-height
      }
    )

    ;; Map principal to volunteer ID
    (map-set volunteer-by-principal tx-sender volunteer-id)

    ;; Update counter
    (var-set next-volunteer-id (+ volunteer-id u1))

    ;; Update preparedness level
    (update-preparedness-level)

    (ok volunteer-id)
  )
)

;; Report available resource
(define-public (report-resource (resource-type (string-ascii 50)) (quantity uint))
  (let
    (
      (resource-id (var-get next-resource-id))
    )
    (asserts! (> quantity u0) ERR-INVALID-INPUT)

    ;; Store resource information
    (map-set emergency-resources resource-id
      {
        resource-type: resource-type,
        quantity: quantity,
        location: "",
        owner: tx-sender,
        available: true,
        last-updated: block-height
      }
    )

    ;; Update counter
    (var-set next-resource-id (+ resource-id u1))

    ;; Update preparedness level
    (update-preparedness-level)

    (ok resource-id)
  )
)

;; Create emergency plan
(define-public (create-emergency-plan (plan-id (string-ascii 50)) (plan-type (string-ascii 50)) (description (string-ascii 500)))
  (begin
    (asserts! (is-none (map-get? emergency-plans plan-id)) ERR-ALREADY-REGISTERED)

    (map-set emergency-plans plan-id
      {
        plan-type: plan-type,
        description: description,
        coordinator: tx-sender,
        status: "Draft",
        last-updated: block-height
      }
    )

    (ok true)
  )
)

;; Activate emergency status (admin only)
(define-public (activate-emergency)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set emergency-status true)
    (ok true)
  )
)

;; Deactivate emergency status (admin only)
(define-public (deactivate-emergency)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set emergency-status false)
    (ok true)
  )
)

;; Request emergency resource
(define-public (request-resource (resource-type (string-ascii 50)) (quantity-needed uint) (urgency-level uint))
  (let
    (
      (request-id (var-get next-resource-id))
    )
    (asserts! (> quantity-needed u0) ERR-INVALID-INPUT)
    (asserts! (> urgency-level u0) ERR-INVALID-INPUT)
    (asserts! (<= urgency-level u5) ERR-INVALID-INPUT)

    (map-set resource-requests request-id
      {
        requester: tx-sender,
        resource-type: resource-type,
        quantity-needed: quantity-needed,
        urgency-level: urgency-level,
        fulfilled: false,
        timestamp: block-height
      }
    )

    (ok request-id)
  )
)

;; Update volunteer availability
(define-public (update-availability (available bool))
  (let
    (
      (volunteer-id (unwrap! (map-get? volunteer-by-principal tx-sender) ERR-VOLUNTEER-NOT-FOUND))
      (volunteer-data (unwrap! (map-get? volunteers volunteer-id) ERR-VOLUNTEER-NOT-FOUND))
    )
    (map-set volunteers volunteer-id
      (merge volunteer-data
        {
          availability: available,
          last-active: block-height
        }
      )
    )

    (ok true)
  )
)

;; Allocate resource to request
(define-public (allocate-resource (resource-id uint) (request-id uint) (quantity uint))
  (let
    (
      (resource (unwrap! (map-get? emergency-resources resource-id) ERR-RESOURCE-NOT-FOUND))
      (request (unwrap! (map-get? resource-requests request-id) ERR-RESOURCE-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender (get owner resource)) ERR-NOT-AUTHORIZED)
    (asserts! (>= (get quantity resource) quantity) ERR-INSUFFICIENT-RESOURCES)
    (asserts! (not (get fulfilled request)) ERR-INVALID-INPUT)

    ;; Update resource quantity
    (map-set emergency-resources resource-id
      (merge resource
        {
          quantity: (- (get quantity resource) quantity),
          last-updated: block-height
        }
      )
    )

    ;; Mark request as fulfilled if fully satisfied
    (if (>= quantity (get quantity-needed request))
      (map-set resource-requests request-id
        (merge request {fulfilled: true})
      )
      true
    )

    (ok true)
  )
)

;; Private Functions

;; Update community preparedness level
(define-private (update-preparedness-level)
  (let
    (
      (volunteer-count (- (var-get next-volunteer-id) u1))
      (resource-count (- (var-get next-resource-id) u1))
      (base-score (+ volunteer-count resource-count))
      (preparedness-score (if (<= (* base-score u10) u1000) (* base-score u10) u1000))
    )
    (var-set preparedness-level preparedness-score)
  )
)

;; Read-only Functions

;; Get emergency status
(define-read-only (get-emergency-status)
  (var-get emergency-status)
)

;; Get preparedness level
(define-read-only (get-preparedness-level)
  (var-get preparedness-level)
)

;; Get volunteer information
(define-read-only (get-volunteer (volunteer-id uint))
  (map-get? volunteers volunteer-id)
)

;; Get volunteer by principal
(define-read-only (get-volunteer-by-principal (volunteer principal))
  (match (map-get? volunteer-by-principal volunteer)
    volunteer-id (map-get? volunteers volunteer-id)
    none
  )
)

;; Get resource information
(define-read-only (get-resource (resource-id uint))
  (map-get? emergency-resources resource-id)
)

;; Get emergency plan
(define-read-only (get-emergency-plan (plan-id (string-ascii 50)))
  (map-get? emergency-plans plan-id)
)

;; Get resource request
(define-read-only (get-resource-request (request-id uint))
  (map-get? resource-requests request-id)
)

;; Check if community is prepared
(define-read-only (is-community-prepared)
  (>= (var-get preparedness-level) u500)
)

;; Get volunteer count
(define-read-only (get-volunteer-count)
  (- (var-get next-volunteer-id) u1)
)

;; Get resource count
(define-read-only (get-resource-count)
  (- (var-get next-resource-id) u1)
)
