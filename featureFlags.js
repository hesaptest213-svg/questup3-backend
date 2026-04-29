const toBoolean = (value, fallback = true) => {
  if (value === undefined || value === null || value === '') {
    return fallback;
  }

  const normalized = String(value).trim().toLowerCase();
  if (['1', 'true', 'yes', 'on'].includes(normalized)) {
    return true;
  }
  if (['0', 'false', 'no', 'off'].includes(normalized)) {
    return false;
  }

  return fallback;
};

export const featureFlags = Object.freeze({
  managedTasks: toBoolean(process.env.FEATURE_MANAGED_TASKS, true),
  taskSubmissions: toBoolean(process.env.FEATURE_TASK_SUBMISSIONS, true),
  adminAccounts: toBoolean(process.env.FEATURE_ADMIN_ACCOUNTS, true),
  qrHunts: toBoolean(process.env.FEATURE_QR_HUNTS, true),
  qrEvents: toBoolean(process.env.FEATURE_QR_EVENTS, true),
  qrDropAssignments: toBoolean(process.env.FEATURE_QR_DROP_ASSIGNMENTS, true),
  giftQrs: toBoolean(process.env.FEATURE_GIFT_QRS, true),
  plusMemberships: toBoolean(process.env.FEATURE_PLUS_MEMBERSHIPS, true),
  shopApplications: toBoolean(process.env.FEATURE_SHOP_APPLICATIONS, true),
  supportTickets: toBoolean(process.env.FEATURE_SUPPORT_TICKETS, true),
  adminUsers: toBoolean(process.env.FEATURE_ADMIN_USERS, true),
  notifications: toBoolean(process.env.FEATURE_NOTIFICATIONS, true),
  liveUsers: toBoolean(process.env.FEATURE_LIVE_USERS, true),
  matches: toBoolean(process.env.FEATURE_MATCHES, true),
  adminNotifications: toBoolean(process.env.FEATURE_ADMIN_NOTIFICATIONS, true),
  trades: toBoolean(process.env.FEATURE_TRADES, true),
  partnerApplications: toBoolean(process.env.FEATURE_PARTNER_APPLICATIONS, true),
  partnerQrCampaigns: toBoolean(process.env.FEATURE_PARTNER_QR_CAMPAIGNS, true),
  groupTasks: toBoolean(process.env.FEATURE_GROUP_TASKS, true),
  eventRewards: toBoolean(process.env.FEATURE_EVENT_REWARDS, true),
});

export function isFeatureEnabled(name) {
  return featureFlags[name] !== false;
}

export function getFeatureFlags() {
  return featureFlags;
}
