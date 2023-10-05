@replaceMethod(WorldMapMenuGameController)
private final func TryTrackQuestOrSetWaypoint() -> Void {
  if this.IsFastTravelEnabled() {
    return;
  };
  if this.selectedMappin != null {
    if this.selectedMappin.IsInCollection() && this.selectedMappin.IsCollection() || !this.selectedMappin.IsInCollection() {
      if this.CanQuestTrackMappin(this.selectedMappin) {
        if !this.IsMappinQuestTracked(this.selectedMappin) {
          this.UntrackCustomPositionMappin();
          this.TrackQuestMappin(this.selectedMappin);
          this.PlaySound(n"MapPin", n"OnEnable");
          this.PlayRumble(RumbleStrength.SuperLight, RumbleType.Slow, RumblePosition.Right);
          inkWidgetRef.SetVisible(this.m_questContainer, true);
        } else {
          // Adds untrack from pin
          this.UntrackCustomPositionMappin();
          this.UntrackQuestMappin();
          this.PlaySound(n"MapPin", n"OnDisable");
          this.PlayRumble(RumbleStrength.SuperLight, RumbleType.Pulse, RumblePosition.Right);
          inkWidgetRef.SetVisible(this.m_questContainer, false);
        }
      } else {
        if this.CanPlayerTrackMappin(this.selectedMappin) {
          if this.selectedMappin.IsCustomPositionTracked() {
            this.UntrackCustomPositionMappin();
            this.SetSelectedMappin(null);
            this.PlaySound(n"MapPin", n"OnDisable");
            this.PlayRumble(RumbleStrength.SuperLight, RumbleType.Pulse, RumblePosition.Right);
          } else {
            if this.selectedMappin.IsPlayerTracked() {
              this.UntrackMappin();
              this.PlaySound(n"MapPin", n"OnDisable");
              this.PlayRumble(RumbleStrength.SuperLight, RumbleType.Pulse, RumblePosition.Right);
            } else {
              this.UntrackCustomPositionMappin();
              this.TrackMappin(this.selectedMappin);
              this.PlaySound(n"MapPin", n"OnEnable");
              this.PlayRumble(RumbleStrength.SuperLight, RumbleType.Slow, RumblePosition.Right);
            };
          };
        };
      };
      this.UpdateSelectedMappinTooltip();
    };
  } else {
    this.TrackCustomPositionMappin();
  };
  this.PlaySound(n"MapPin", n"OnCreate");
}

// Fix a vanilla bug with erroneus check
@replaceMethod(WorldMapMenuGameController)
public final const func IsMappinQuestTracked(mappin: wref<IMappin>) -> Bool {
  let journalEntry: ref<JournalEntry>;
  if mappin != null {
    journalEntry = this.GetMappinJournalEntry(mappin);
    if journalEntry != null {
      return this.m_journalManager.IsEntryTracked(journalEntry);
    };
  };
  return false;
}

@addMethod(WorldMapMenuGameController)
private final func UntrackQuestMappin() -> Void {
  this.m_journalManager.UntrackEntry();
}
