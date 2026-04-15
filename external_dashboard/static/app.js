(function () {
  const refreshButton = document.getElementById("btnRefresh");
  const autoButton = document.getElementById("btnAuto");
  let autoOn = true;
  let timer = null;

  function refreshNow() {
    window.location.reload();
  }

  function setAuto(on) {
    autoOn = on;
    autoButton.textContent = on ? "Auto: ON" : "Auto: OFF";
    if (timer) {
      clearInterval(timer);
      timer = null;
    }
    if (on) {
      timer = setInterval(refreshNow, 5000);
    }
  }

  if (refreshButton) {
    refreshButton.addEventListener("click", refreshNow);
  }
  if (autoButton) {
    autoButton.addEventListener("click", function () {
      setAuto(!autoOn);
    });
    setAuto(true);
  }
})();
