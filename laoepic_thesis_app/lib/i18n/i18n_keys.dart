/// Keys for [assets/i18n/en.json] and [assets/i18n/lo.json].
abstract final class I18nKey {
  // Common
  static const commonCancel = 'common.cancel';
  static const commonOk = 'common.ok';
  static const commonClose = 'common.close';
  static const commonConfirm = 'common.confirm';
  static const commonEmDash = 'common.emDash';
  static const commonOr = 'common.or';
  static const commonContinue = 'common.continue';
  static const commonSearch = 'common.search';
  static const commonSeeAll = 'common.seeAll';
  static const commonLoading = 'common.loading';
  static const commonRefresh = 'common.refresh';
  static const commonTryAgain = 'common.tryAgain';
  static const commonNetworkError = 'common.networkError';
  static const feedbackSuccess = 'feedback.success';
  static const feedbackError = 'feedback.error';
  static const feedbackWarning = 'feedback.warning';
  static const feedbackInfo = 'feedback.info';
  static const feedbackBusinessNoticeTitle = 'feedback.businessNoticeTitle';
  static const feedbackBusinessNoticeHint = 'feedback.businessNoticeHint';
  static const feedbackTechnicalIssueTitle = 'feedback.technicalIssueTitle';
  static const feedbackTechnicalIssueHint = 'feedback.technicalIssueHint';

  // Bottom nav
  static const navHome = 'nav.home';
  static const navPackage = 'nav.package';
  static const navFavorite = 'nav.favorite';
  static const navTrip = 'nav.trip';
  static const navAccount = 'nav.account';

  // Home
  static const homePopularProvince = 'home.popularProvince';
  static const homePopularActivities = 'home.popularActivities';
  static const homePopularPlaceLaos = 'home.popularPlaceLaos';
  static const homeOtherActions = 'home.otherActions';
  static const homeActionTravel = 'home.actionTravel';
  static const homeActionPlan = 'home.actionPlan';
  static const homeActionEvent = 'home.actionEvent';
  static const homeActionBooking = 'home.actionBooking';
  static const homeActionCollection = 'home.actionCollection';
  static const homePlaceVientiane = 'home.placeVientiane';
  static const homePlaceKuangsi = 'home.placeKuangsi';
  static const homePlaceThatLuang = 'home.placeThatLuang';
  static const homeFeaturedPackages = 'home.featuredPackages';
  static const homeBestTopSeasons = 'home.bestTopSeasons';
  static const homeBestTopEmpty = 'home.bestTopEmpty';
  static const homeBestTopPackageCount = 'home.bestTopPackageCount';

  // Package list / detail shell
  static const packageAllPackages = 'package.allPackages';
  static const packageClearFilter = 'package.clearFilter';
  static const packageNoPackagesFound = 'package.noPackagesFound';
  static const packageDetailTitle = 'package.detailTitle';
  static const packageTabPackage = 'package.tabPackage';
  static const packageTabAbout = 'package.tabAbout';
  static const packageTabDepartures = 'package.tabDepartures';
  static const packageDurationDaysShort = 'package.durationDaysShort';

  // Favorites
  static const favoriteTitle = 'favorite.title';
  static const favoriteEmpty = 'favorite.empty';
  static const favoriteRemoved = 'favorite.removed';

  // Booking history
  static const historyTitle = 'history.title';
  static const historyError = 'history.error';
  static const historyEmpty = 'history.empty';
  static const historyTotal = 'history.total';
  static const historyCollectionPoints = 'history.collectionPoints';
  static const historyCancel = 'history.cancel';
  static const historyCancelTitle = 'history.cancelTitle';
  static const historyCancelConfirm = 'history.cancelConfirm';
  static const historyCancelPolicyTitle = 'history.cancelPolicyTitle';
  static const historyReasonLabel = 'history.reasonLabel';
  static const historyReasonHint = 'history.reasonHint';
  static const historyCancelSuccess = 'history.cancelSuccess';
  static const historyCancelRequestSubmitted =
      'history.cancelRequestSubmitted';
  static const historyCancelConfirmRequest = 'history.cancelConfirmRequest';
  static const historyCancelPolicyAgree = 'history.cancelPolicyAgree';
  static const historyCancelPending = 'history.cancelPending';
  static const historyCancelFail = 'history.cancelFail';
  static const historyCancelFailGeneric = 'history.cancelFailGeneric';
  static const historyCancelTooLate = 'history.cancelTooLate';
  static const historyNotLoggedIn = 'history.notLoggedIn';
  static const historyLoadFail = 'history.loadFail';
  static const historyFilterAll = 'history.filterAll';
  static const historyFilterPending = 'history.filterPending';
  static const historyFilterConfirmed = 'history.filterConfirmed';
  static const historyFilterCancelled = 'history.filterCancelled';
  static const historyViewDetails = 'history.viewDetails';
  static const historyCompletePayment = 'history.completePayment';
  static const historyBookingRef = 'history.bookingRef';
  static const historyTravelersCount = 'history.travelersCount';
  static const historyEmptyTitle = 'history.emptyTitle';
  static const historyEmptyMessage = 'history.emptyMessage';
  static const historyErrorTitle = 'history.errorTitle';

  // Packet tab
  static const packetType = 'packet.type';
  static const packetDuration = 'packet.duration';
  static const packetProvider = 'packet.provider';
  static const packetGuide = 'packet.guide';
  static const packetGallery = 'packet.gallery';
  static const packetOverview = 'packet.overview';
  static const packetBookNow = 'packet.bookNow';
  static const packetHighlights = 'packet.highlights';
  static const packetFacilities = 'packet.facilities';
  static const packetActivities = 'packet.activities';
  static const packetPreviewHint = 'packet.previewHint';
  static const packetReviewsPlaceholder = 'packet.reviewsPlaceholder';
  static const packetAllReviews = 'packet.allReviews';
  static const packetNoReviews = 'packet.noReviews';
  static const packetReviewActivityTag = 'packet.reviewActivityTag';
  static const packetServiceTravel = 'packet.serviceTravel';
  static const packetServiceHotel = 'packet.serviceHotel';
  static const packetServiceActivity = 'packet.serviceActivity';
  static const packetServiceGuide = 'packet.serviceGuide';

  // About tab
  static const aboutDescription = 'about.description';
  static const aboutLocaleLine = 'about.localeLine';
  static const aboutCouldNotOpen = 'about.couldNotOpen';
  static const aboutGettingThere = 'about.gettingThere';
  static const aboutActivities = 'about.activities';
  static const aboutFeesExtras = 'about.feesExtras';
  static const aboutFacilities = 'about.facilities';
  static const aboutOpeningHours = 'about.openingHours';
  static const aboutTipsVisitors = 'about.tipsVisitors';
  static const aboutMustBring = 'about.mustBring';
  static const aboutOptionalBring = 'about.optionalBring';
  static const aboutBookNow = 'about.bookNow';
  static const aboutSocial = 'about.social';
  static const aboutProvider = 'about.provider';
  static const aboutGuide = 'about.guide';
  static const packageGuideNote = 'package.guideNote';
  static const invoiceGuideDetail = 'invoice.guideDetail';
  static const invoiceGuideName = 'invoice.guideName';
  static const invoiceGuidePhone = 'invoice.guidePhone';
  static const invoiceGuideEmail = 'invoice.guideEmail';
  static const aboutPriceFrom = 'about.priceFrom';
  static const aboutSuggestedDuration = 'about.suggestedDuration';

  // Departures tab
  static const departuresEmptyTitle = 'departures.emptyTitle';
  static const departuresEmptyBody = 'departures.emptyBody';
  static const departuresHeaderTitle = 'departures.headerTitle';
  static const departuresSuggestedDays = 'departures.suggestedDays';
  static const departuresPickBelow = 'departures.pickBelow';
  static const departuresLabelDeparture = 'departures.labelDeparture';
  static const departuresLabelReturn = 'departures.labelReturn';
  static const departuresAvailability = 'departures.availability';
  static const departuresSeatsLeft = 'departures.seatsLeft';
  static const departuresPrices = 'departures.prices';
  static const departuresPriceAdult = 'departures.priceAdult';
  static const departuresPriceChild = 'departures.priceChild';
  static const departuresPriceVip = 'departures.priceVip';

  // Auth login
  static const authLoginTitle = 'auth.loginTitle';
  static const authEmailHint = 'auth.emailHint';
  static const authPasswordHint = 'auth.passwordHint';
  static const authForgotPassword = 'auth.forgotPassword';
  static const authEnterEmailPassword = 'auth.enterEmailPassword';
  static const authLoginFailedCode = 'auth.loginFailedCode';
  static const authLoginFailedNoToken = 'auth.loginFailedNoToken';
  static const authLoginFailedGeneric = 'auth.loginFailedGeneric';
  static const authSignInNotCompleted = 'auth.signInNotCompleted';
  static const authLoginWithGoogle = 'auth.loginWithGoogle';
  static const authLoginWithFacebook = 'auth.loginWithFacebook';
  static const authCreateNewAccount = 'auth.createNewAccount';

  // Auth signup
  static const authSignUpTitle = 'auth.signUpTitle';
  static const authSignUpName = 'auth.signUpName';
  static const authSignUpEmail = 'auth.signUpEmail';
  static const authSignUpPassword = 'auth.signUpPassword';
  static const authCreateAccount = 'auth.createAccount';
  static const authSignUpFailed = 'auth.signUpFailed';

  static const authVerifyOtpTitle = 'auth.verifyOtpTitle';
  static const authOtpCodeHint = 'auth.otpCodeHint';
  static const authVerifyOtpButton = 'auth.verifyOtpButton';
  static const authEnterOtp = 'auth.enterOtp';
  static const authInvalidOtp = 'auth.invalidOtp';
  static const authResendOtp = 'auth.resendOtp';
  static const authOtpResent = 'auth.otpResent';
  static const authServerConnectFailed = 'auth.serverConnectFailed';
  static const authEmailVerifiedLogin = 'auth.emailVerifiedLogin';
  static const authForgotPasswordTitle = 'auth.forgotPasswordTitle';
  static const authRequestOtpReset = 'auth.requestOtpReset';
  static const authFailedWithBody = 'auth.failedWithBody';
  static const authResetPasswordTitle = 'auth.resetPasswordTitle';
  static const authNewPassword = 'auth.newPassword';
  static const authResetPasswordButton = 'auth.resetPasswordButton';
  static const authResetSuccess = 'auth.resetSuccess';
  static const authChangePasswordTitle = 'auth.changePasswordTitle';
  static const authPasswordRules = 'auth.passwordRules';
  static const authCurrentPassword = 'auth.currentPassword';
  static const authNewPasswordLabel = 'auth.newPasswordLabel';
  static const authConfirmNewPassword = 'auth.confirmNewPassword';
  static const authForgotYourPassword = 'auth.forgotYourPassword';
  static const authLogoutOtherDevices = 'auth.logoutOtherDevices';
  static const authUserIdNotLoaded = 'auth.userIdNotLoaded';
  static const authFillAllFields = 'auth.fillAllFields';
  static const authPasswordsNoMatch = 'auth.passwordsNoMatch';
  static const authPasswordUpdated = 'auth.passwordUpdated';
  static const authOldPasswordWrong = 'auth.oldPasswordWrong';
  static const authEditEmailTitle = 'auth.editEmailTitle';
  static const authEmailHintEnter = 'auth.emailHintEnter';
  static const authUsernameRules = 'auth.usernameRules';
  static const authSave = 'auth.save';
  static const authEmailUpdated = 'auth.emailUpdated';
  static const authEmailUpdateFailed = 'auth.emailUpdateFailed';
  static const authEditProfileHubTitle = 'auth.editProfileHubTitle';
  static const authEditUsernameTitle = 'auth.editUsernameTitle';
  static const authFirstNameHint = 'auth.firstNameHint';
  static const authLastNameHint = 'auth.lastNameHint';
  static const authPhoneHint = 'auth.phoneHint';
  static const authProfileUpdated = 'auth.profileUpdated';
  static const authProfileUpdateFailed = 'auth.profileUpdateFailed';
  static const authUploadFailed = 'auth.uploadFailed';
  static const authProfilePhotoUpdated = 'auth.profilePhotoUpdated';
  static const authSaveProfilePhoto = 'auth.saveProfilePhoto';
  static const authUsernameLabel = 'auth.usernameLabel';
  static const authTapUpdateUsername = 'auth.tapUpdateUsername';
  static const authTapUpdateEmail = 'auth.tapUpdateEmail';
  static const authTapUpdatePassword = 'auth.tapUpdatePassword';

  // Intro / start
  static const introPlanYour = 'intro.planYour';
  static const introEpicVacation = 'intro.epicVacation';
  static const introGetStarted = 'intro.getStarted';

  // Booking form
  static const bookingFormTitle = 'bookingForm.title';
  static const bookingFormSubtitle = 'bookingForm.subtitle';
  static const bookingFormDeparture = 'bookingForm.departure';
  static const bookingFormSelectDeparture = 'bookingForm.selectDeparture';
  static const bookingFormNoDepartures = 'bookingForm.noDepartures';
  static const bookingFormYourInfo = 'bookingForm.yourInfo';
  static const bookingFormFirstName = 'bookingForm.firstName';
  static const bookingFormLastName = 'bookingForm.lastName';
  static const bookingFormPhone = 'bookingForm.phone';
  static const bookingFormEmail = 'bookingForm.email';
  static const bookingFormBirth = 'bookingForm.birth';
  static const bookingFormNationality = 'bookingForm.nationality';
  static const bookingFormPassport = 'bookingForm.passport';
  static const bookingFormNote = 'bookingForm.note';
  static const bookingFormBookPay = 'bookingForm.bookPay';
  static const bookingFormSelectDepartureSnackbar = 'bookingForm.selectDepartureSnackbar';
  static const bookingFormInvalidBirth = 'bookingForm.invalidBirth';
  static const bookingFormMustLogin = 'bookingForm.mustLogin';
  static const bookingFormBookingFailed = 'bookingForm.bookingFailed';
  static const bookingFormInvalidBookingResponse = 'bookingForm.invalidBookingResponse';
  static const bookingFormBookingCreated = 'bookingForm.bookingCreated';
  static const bookingFormInvoiceFailBody = 'bookingForm.invoiceFailBody';
  static const bookingFormInvoiceReadyBody = 'bookingForm.invoiceReadyBody';
  static const bookingFormNoPaymentUrl = 'bookingForm.noPaymentUrl';
  static const bookingFormCouldNotOpenBrowser = 'bookingForm.couldNotOpenBrowser';
  static const bookingFormPayNowTitle = 'bookingForm.payNowTitle';
  static const bookingFormPayNowBody = 'bookingForm.payNowBody';
  static const bookingFormRequired = 'bookingForm.required';
  static const bookingFormScheduleSeats = 'bookingForm.scheduleSeats';
  static const bookingFormLoadDeparturesFailed = 'bookingForm.loadDeparturesFailed';
  static const bookingFormErrorPrefix = 'bookingForm.errorPrefix';
  static const bookingFormStepDeparture = 'bookingForm.stepDeparture';
  static const bookingFormStepDetails = 'bookingForm.stepDetails';
  static const bookingFormStepReview = 'bookingForm.stepReview';
  static const bookingFormReviewTitle = 'bookingForm.reviewTitle';
  static const bookingFormReviewSubtitle = 'bookingForm.reviewSubtitle';
  static const bookingFormSeatsLeft = 'bookingForm.seatsLeft';
  static const bookingFormReturnDate = 'bookingForm.returnDate';
  static const bookingFormTraveler = 'bookingForm.traveler';
  static const bookingFormPaymentNote = 'bookingForm.paymentNote';
  static const bookingFormTravelersCount = 'bookingForm.travelersCount';
  static const bookingFormTravelerNumber = 'bookingForm.travelerNumber';
  static const bookingFormTravelerNameRequired = 'bookingForm.travelerNameRequired';
  static const bookingFormContactInfo = 'bookingForm.contactInfo';
  static const bookingFormPayLater = 'bookingForm.payLater';
  static const bookingFormPayLaterBody = 'bookingForm.payLaterBody';
  static const bookingFormPaymentPolicy = 'bookingForm.paymentPolicy';
  static const bookingFormPaymentMinDays = 'bookingForm.paymentMinDays';
  static const bookingFormRetryLoad = 'bookingForm.retryLoad';
  static const bookingFormSelectDepartureHint = 'bookingForm.selectDepartureHint';
  static const bookingFormBack = 'bookingForm.back';
  static const bookingFormNoPriceTier = 'bookingForm.noPriceTier';
  static const bookingFormNotEnoughSeats = 'bookingForm.notEnoughSeats';
  static const bookingFormDuplicateBooking = 'bookingForm.duplicateBooking';

  // Booking detail
  static const bookingDetailTitle = 'bookingDetail.title';
  static const bookingDetailPleaseSignIn = 'bookingDetail.pleaseSignIn';
  static const bookingDetailFailedLoad = 'bookingDetail.failedLoad';
  static const bookingDetailRefreshFailed = 'bookingDetail.refreshFailed';
  static const bookingDetailInvalidLink = 'bookingDetail.invalidLink';
  static const bookingDetailCouldNotOpenLink = 'bookingDetail.couldNotOpenLink';
  static const bookingDetailCouldNotCreateInvoice = 'bookingDetail.couldNotCreateInvoice';
  static const bookingDetailCouldNotRequestPaymentLink = 'bookingDetail.couldNotRequestPaymentLink';
  static const bookingDetailNoPaymentUrl = 'bookingDetail.noPaymentUrl';
  static const bookingDetailCouldNotOpenBrowser = 'bookingDetail.couldNotOpenBrowser';
  static const bookingDetailOpenedPhajay = 'bookingDetail.openedPhajay';

  static const bookingDetailNavOverview = 'bookingDetail.navOverview';
  static const bookingDetailNavPackage = 'bookingDetail.navPackage';
  static const bookingDetailNavDates = 'bookingDetail.navDates';
  static const bookingDetailNavPay = 'bookingDetail.navPay';
  static const bookingDetailNavInvoice = 'bookingDetail.navInvoice';
  static const bookingDetailNavVoucher = 'bookingDetail.navVoucher';
  static const bookingDetailNavCancelled = 'bookingDetail.navCancelled';
  static const bookingDetailNavReview = 'bookingDetail.navReview';
  static const bookingDetailNavGuests = 'bookingDetail.navGuests';
  static const bookingDetailNavSystem = 'bookingDetail.navSystem';

  static const bookingDetailStatusPending = 'bookingDetail.statusPending';
  static const bookingDetailStatusPaid = 'bookingDetail.statusPaid';
  static const bookingDetailStatusConfirmed = 'bookingDetail.statusConfirmed';
  static const bookingDetailStatusCancelled = 'bookingDetail.statusCancelled';
  static const bookingDetailStatusExpired = 'bookingDetail.statusExpired';
  static const bookingDetailStatusFailed = 'bookingDetail.statusFailed';

  static const bookingDetailSectionPackage = 'bookingDetail.sectionPackage';
  static const bookingDetailSectionTravelDates = 'bookingDetail.sectionTravelDates';
  static const bookingDetailLabelDeparture = 'bookingDetail.labelDeparture';
  static const bookingDetailLabelReturn = 'bookingDetail.labelReturn';
  static const bookingDetailLabelBookedOn = 'bookingDetail.labelBookedOn';
  static const bookingDetailLabelPassengers = 'bookingDetail.labelPassengers';
  static const bookingDetailLabelPayBefore = 'bookingDetail.labelPayBefore';
  static const bookingDetailSectionPayment = 'bookingDetail.sectionPayment';
  static const bookingDetailPayWithPhajay = 'bookingDetail.payWithPhajay';
  static const bookingDetailSectionInvoice = 'bookingDetail.sectionInvoice';
  static const bookingDetailLabelNumber = 'bookingDetail.labelNumber';
  static const bookingDetailLabelInvoiceStatus = 'bookingDetail.labelInvoiceStatus';
  static const bookingDetailLabelGrandTotal = 'bookingDetail.labelGrandTotal';
  static const bookingDetailLabelPaymentDetails = 'bookingDetail.labelPaymentDetails';
  static const bookingDetailSectionVoucher = 'bookingDetail.sectionVoucher';
  static const bookingDetailLabelStatus = 'bookingDetail.labelStatus';
  static const bookingDetailQr = 'bookingDetail.qr';
  static const bookingDetailPdf = 'bookingDetail.pdf';
  static const bookingDetailSectionCancellation = 'bookingDetail.sectionCancellation';
  static const bookingDetailLabelRequestStatus = 'bookingDetail.labelRequestStatus';
  static const bookingDetailSectionYourReview = 'bookingDetail.sectionYourReview';
  static const bookingDetailSectionBookerPassengers = 'bookingDetail.sectionBookerPassengers';
  static const bookingDetailLabelName = 'bookingDetail.labelName';
  static const bookingDetailLabelEmail = 'bookingDetail.labelEmail';
  static const bookingDetailLabelPhone = 'bookingDetail.labelPhone';
  static const bookingDetailPassengersCount = 'bookingDetail.passengersCount';
  static const bookingDetailNoPassengersOnFile = 'bookingDetail.noPassengersOnFile';
  static const bookingDetailNote = 'bookingDetail.note';
  static const bookingDetailSectionSystem = 'bookingDetail.sectionSystem';
  static const bookingDetailLabelScheduleId = 'bookingDetail.labelScheduleId';
  static const bookingDetailLabelCreated = 'bookingDetail.labelCreated';
  static const bookingDetailLabelLastUpdated = 'bookingDetail.labelLastUpdated';
  static const bookingDetailLabelPackageLanguage = 'bookingDetail.labelPackageLanguage';

  static const bookingDetailReadMore = 'bookingDetail.readMore';
  static const bookingDetailReadLess = 'bookingDetail.readLess';
  static const bookingDetailShowMorePassengers = 'bookingDetail.showMorePassengers';
  static const bookingDetailShowingFirstAbove = 'bookingDetail.showingFirstAbove';
  static const bookingDetailBookingNumber = 'bookingDetail.bookingNumber';
  static const bookingDetailDateOfBirth = 'bookingDetail.dateOfBirth';
  static const bookingDetailDocument = 'bookingDetail.document';
  static const bookingDetailMoreFromPackage = 'bookingDetail.moreFromPackage';
  static const bookingDetailBulletGettingThere = 'bookingDetail.bulletGettingThere';
  static const bookingDetailBulletActivities = 'bookingDetail.bulletActivities';
  static const bookingDetailBulletFees = 'bookingDetail.bulletFees';
  static const bookingDetailBulletFacilities = 'bookingDetail.bulletFacilities';
  static const bookingDetailBulletOpening = 'bookingDetail.bulletOpening';
  static const bookingDetailBulletTips = 'bookingDetail.bulletTips';
  static const bookingDetailBulletMustBring = 'bookingDetail.bulletMustBring';
  static const bookingDetailBulletOptionalBring = 'bookingDetail.bulletOptionalBring';
  static const bookingDetailBulletTruncatedMore =
      'bookingDetail.bulletTruncatedMore';

  // Notifications
  static const notificationsTitle = 'notifications.title';
  static const notificationsLoading = 'notifications.loading';
  static const notificationsMarkAllRead = 'notifications.markAllRead';
  static const notificationsErrorTitle = 'notifications.errorTitle';
  static const notificationsTryAgain = 'notifications.tryAgain';
  static const notificationsEmptyTitle = 'notifications.emptyTitle';
  static const notificationsEmptyMessage = 'notifications.emptyMessage';
  static const notificationsRefresh = 'notifications.refresh';
  static const notificationsFallbackTitle = 'notifications.fallbackTitle';
  static const notificationsBookingUpdate = 'notifications.bookingUpdate';
  static const notificationsBookingHash = 'notifications.bookingHash';
  static const notificationsStatusLine = 'notifications.statusLine';
  static const notificationsNeedLogin = 'notifications.needLogin';
  static const notificationsLoadFailed = 'notifications.loadFailed';
  static const notificationsNetworkError = 'notifications.networkError';

  // Account
  static const accountSignOut = 'account.signOut';
  static const accountSignOutConfirm = 'account.signOutConfirm';
  static const accountEditProfile = 'account.editProfile';
  static const accountEditProfileSubtitle = 'account.editProfileSubtitle';
  static const accountChangePassword = 'account.changePassword';
  static const accountLanguageTitle = 'account.languageTitle';
  static const accountYourPosts = 'account.yourPosts';
  static const accountYourReviews = 'account.yourReviews';
  static const accountHelp = 'account.help';
  static const accountContactSupport = 'account.contactSupport';
  static const accountSafetyCenter = 'account.safetyCenter';
  static const accountSendFeedback = 'account.sendFeedback';
  static const accountLoadProfileError = 'account.loadProfileError';
  static const accountNetworkError = 'account.networkError';
  static const accountLocaleEnglish = 'account.localeEnglish';
  static const accountLocaleThai = 'account.localeThai';
  static const accountLocaleLao = 'account.localeLao';

  // Invoice (full page)
  static const invoiceTitle = 'invoice.title';
  static const invoiceHeading = 'invoice.heading';
  static const invoiceLoadFailed = 'invoice.loadFailed';
  static const invoiceAlreadyPaid = 'invoice.alreadyPaid';
  static const invoiceCustomer = 'invoice.customer';
  static const invoiceBookingId = 'invoice.bookingId';
  static const invoiceBookingStatus = 'invoice.bookingStatus';
  static const invoiceTravelersCount = 'invoice.travelersCount';
  static const invoiceTravelersLine = 'invoice.travelersLine';
  static const invoiceDeparture = 'invoice.departure';
  static const invoiceDate = 'invoice.date';
  static const invoiceTravelersSection = 'invoice.travelersSection';
  static const invoiceNoTravelers = 'invoice.noTravelers';
  static const invoiceSubtotal = 'invoice.subtotal';
  static const invoiceTax = 'invoice.tax';
  static const invoiceGrandTotal = 'invoice.grandTotal';
  static const invoicePayNow = 'invoice.payNow';
  static const invoiceViewFull = 'invoice.viewFull';
  static const invoiceDownloadPdf = 'invoice.downloadPdf';
  static const invoiceDownloadingPdf = 'invoice.downloadingPdf';
  static const invoicePdfError = 'invoice.pdfError';
  static const invoiceActivityTitle = 'invoice.activityTitle';
  static const invoiceTravelerName = 'invoice.travelerName';
  static const invoiceStatusPaid = 'invoice.status_paid';
  static const invoiceStatusConfirmed = 'invoice.status_confirmed';
  static const invoiceStatusVoid = 'invoice.status_void';
  static const invoiceStatusPaymentPending = 'invoice.status_payment_pending';
  static const invoiceStatusAwaitingPayment = 'invoice.status_awaiting_payment';
  static const invoiceStatusBookingPaid = 'invoice.status_booking_paid';

  // Home (extended)
  static const homeHeroTagline = 'home.heroTagline';
  static const homeTopExperiencesTitle = 'home.topExperiencesTitle';
  static const homeTopExperiencesSubtitle = 'home.topExperiencesSubtitle';
  static const homeSeeMore = 'home.seeMore';
  static const homeReviewsTitle = 'home.reviewsTitle';
  static const homeReviewsBadge = 'home.reviewsBadge';
  static const homeReviewsSubtitle = 'home.reviewsSubtitle';
  static const homeOurServicesTitle = 'home.ourServicesTitle';
  static const homeServiceDiscover = 'home.serviceDiscover';
  static const homeServiceTrusted = 'home.serviceTrusted';
  static const homeServiceSupport = 'home.serviceSupport';
  static const homeServiceSecurePay = 'home.serviceSecurePay';

  // Payment return
  static const paymentReturnTitle = 'payment.return.title';
  static const paymentReturnVerifyingTitle = 'payment.return.verifyingTitle';
  static const paymentReturnVerifyingDesc = 'payment.return.verifyingDesc';
  static const paymentReturnSuccessTitle = 'payment.return.successTitle';
  static const paymentReturnSuccessDesc = 'payment.return.successDesc';
  static const paymentReturnFailedTitle = 'payment.return.failedTitle';
  static const paymentReturnFailedDesc = 'payment.return.failedDesc';
  static const paymentReturnUnknownTitle = 'payment.return.unknownTitle';
  static const paymentReturnUnknownDesc = 'payment.return.unknownDesc';
  static const paymentReturnViewBooking = 'payment.return.viewBooking';

  // Info pages
  static const infoAboutTitle = 'info.about.title';
  static const infoAboutBody = 'info.about.body';
  static const infoContactTitle = 'info.contact.title';
  static const infoContactBody = 'info.contact.body';
  static const infoHelpTitle = 'info.help.title';
  static const infoHelpBody = 'info.help.body';

  static const accountAboutUs = 'account.aboutUs';
  static const accountHelpCenter = 'account.helpCenter';

  static const authGoogleNotConfigured = 'auth.googleNotConfigured';
  static const authGoogleIosNotConfigured = 'auth.googleIosNotConfigured';
  static const authGoogleSignInCancelled = 'auth.googleSignInCancelled';

  static const bookingFormInsuranceLabel = 'bookingForm.insuranceLabel';
  static const bookingFormInsuranceHint = 'bookingForm.insuranceHint';
  static const bookingFormInsuranceNote = 'bookingForm.insuranceNote';
  static const bookingFormInsuranceYes = 'bookingForm.insuranceYes';
  static const bookingFormTermsAcceptPrefix = 'bookingForm.termsAcceptPrefix';
  static const bookingFormTermsRequired = 'bookingForm.termsRequired';
  static const txtAboutUs = 'txt.about_us';
  static const helpTitle = 'help.title';
  static const bookingFormPayBank = 'bookingForm.payBank';

  static const paymentQrTitle = 'payment.qrTitle';
  static const paymentQrScanHint = 'payment.qrScanHint';
  static const paymentQrWaiting = 'payment.qrWaiting';
  static const paymentQrOpenLink = 'payment.qrOpenLink';
  static const paymentQrWalletCap = 'payment.qrWalletCap';
  static const paymentQrBankCap = 'payment.qrBankCap';

  static const bookingDetailCancelNow = 'bookingDetail.cancelNow';
  static const bookingDetailRefundTitle = 'bookingDetail.refundTitle';
  static const bookingDetailRefundPending = 'bookingDetail.refundPending';
  static const bookingDetailRefundCompleted = 'bookingDetail.refundCompleted';
  static const bookingDetailRefundDeclined = 'bookingDetail.refundDeclined';

  static const reviewWriteTitle = 'review.writeTitle';
  static const reviewSubmit = 'review.submit';
  static const reviewCommentHint = 'review.commentHint';
  static const reviewRatingRequired = 'review.ratingRequired';
  static const reviewCommentRequired = 'review.commentRequired';
  static const reviewSuccessText = 'review.successText';
  static const reviewSubmittedLabel = 'review.submittedLabel';
  static const reviewOpensAfterTrip = 'review.opensAfterTrip';
  static const reviewOpensAfterTripGeneric = 'review.opensAfterTripGeneric';
  static const reviewWindowClosed = 'review.windowClosed';
}
