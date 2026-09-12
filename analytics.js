/* =========================================================
   AK ELECTRONICS PRO — ANALYTICS (self-hosted, no Google Analytics)
   Logs page views + key clicks (WhatsApp, Add to Cart, Order Placed)
   into Supabase so the Admin Panel can show real traffic numbers.
   Fails silently — never breaks the site if Supabase is slow/down.
   ========================================================= */

function akGetSessionId(){
  try{
    let id = localStorage.getItem("ak_session_id");
    if (!id){
      id = (crypto.randomUUID ? crypto.randomUUID() : (Date.now() + "-" + Math.random().toString(36).slice(2)));
      localStorage.setItem("ak_session_id", id);
    }
    return id;
  } catch(e){ return "unknown"; }
}

function akDeviceType(){
  return window.matchMedia && window.matchMedia("(max-width: 768px)").matches ? "mobile" : "desktop";
}

function akNormalizeReferrer(ref){
  if (!ref) return "direct";
  const r = ref.toLowerCase();
  if (r.includes("google")) return "google";
  if (r.includes("facebook") || r.includes("fb.com")) return "facebook";
  if (r.includes("instagram")) return "instagram";
  if (r.includes("whatsapp") || r.includes("wa.me")) return "whatsapp";
  if (r.includes("l.instagram.com")) return "instagram";
  return "other";
}

// Waits briefly for the global `supabase` client (set up in script.js)
// to be ready, since this script may run before init finishes.
function akWaitForSupabase(cb, attemptsLeft){
  if (attemptsLeft === undefined) attemptsLeft = 20;
  if (typeof supabase !== "undefined" && supabase){ cb(); return; }
  if (attemptsLeft <= 0) return;
  setTimeout(() => akWaitForSupabase(cb, attemptsLeft - 1), 250);
}

function logAnalyticsEvent(eventType, extra){
  extra = extra || {};
  akWaitForSupabase(() => {
    supabase.from("analytics_events").insert({
      event_type: eventType,
      page_path: window.location.pathname,
      product_id: extra.product_id || null,
      referrer: akNormalizeReferrer(document.referrer),
      device_type: akDeviceType(),
      session_id: akGetSessionId()
    }).then(() => {}, () => {}); // never let a failed log break the page
  });
}
window.logAnalyticsEvent = logAnalyticsEvent;

// Log one page_view per page load automatically
logAnalyticsEvent("page_view");
