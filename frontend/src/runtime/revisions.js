(function () {
  const runtime = window.ShinyblocksRuntimeParts ||= {};
  const revisions = new Map();

  runtime.isFreshRevision = function isFreshRevision(id, revision) {
    const next = Number(revision || 0);
    const current = revisions.get(id) || 0;
    if (next < current) return false;
    revisions.set(id, next);
    return true;
  };

  runtime.forgetRevision = function forgetRevision(id) {
    revisions.delete(id);
  };
})();
