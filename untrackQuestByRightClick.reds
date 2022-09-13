@replaceMethod(questLogGameController)
protected cb func OnRequestChangeTrackedObjective(e: ref<RequestChangeTrackedObjective>) -> Bool {
  let data: ref<QuestListItemData>;
  let i: Int32;
  let updateEvent: ref<UpdateTrackedObjectiveEvent>;
  if NotEquals(this.m_journalManager.GetEntryState(e.m_quest), gameJournalEntryState.Failed) && NotEquals(this.m_journalManager.GetEntryState(e.m_quest), gameJournalEntryState.Succeeded) {
      if e.m_objective == null {
        e.m_objective = this.GetFirstObjectiveFromQuest(e.m_quest);
      };
      // Check for current quest
      let m_trackedEntry = this.m_journalManager.GetTrackedEntry() as JournalQuestObjective;
      let m_trackedPhase = this.m_journalManager.GetParentEntry(m_trackedEntry) as JournalQuestPhase;
      let m_trackedQuest = this.m_journalManager.GetParentEntry(m_trackedPhase) as JournalQuest;
      if Equals(m_trackedQuest.GetTitle(this.m_journalManager), e.m_quest.GetTitle(this.m_journalManager)) {
        let dummy: wref<JournalEntry>;
        this.m_journalManager.TrackEntry(dummy);
        updateEvent = new UpdateTrackedObjectiveEvent();
        updateEvent.m_trackedObjective = null;
        updateEvent.m_trackedQuest = null;
      } else {
        // Old logic
        this.m_journalManager.TrackEntry(e.m_objective);
        updateEvent = new UpdateTrackedObjectiveEvent();
        updateEvent.m_trackedObjective = e.m_objective;
        updateEvent.m_trackedQuest = questLogGameController.GetTopQuestEntry(this.m_journalManager, e.m_objective);
      }
      // Rest unchanged
      this.PlaySound(n"MapPin", n"OnCreate");
      this.m_trackedQuest = updateEvent.m_trackedQuest;
      this.QueueEvent(updateEvent);
      i = 0;
      while i < ArraySize(this.m_listData) {
        data = this.m_listData[i].m_data as QuestListItemData;
        if IsDefined(data) {
            data.m_isTrackedQuest = updateEvent.m_trackedQuest == data.m_questData;
        };
        i += 1;
      };
  };
}

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
          // Enforce a questbox update, fixes vanilla bug
          inkWidgetRef.SetVisible(this.m_questContainer, true);
        } else {
          // Adds untrack from pin
          this.UntrackCustomPositionMappin();
          this.UntrackQuestMappin();
          this.PlaySound(n"MapPin", n"OnDisable");
          // Enforce a questbox update, fixes vanilla bug
          inkWidgetRef.SetVisible(this.m_questContainer, false);
        }
      } else {
        if this.CanPlayerTrackMappin(this.selectedMappin) {
          if this.selectedMappin.IsCustomPositionTracked() {
            this.UntrackCustomPositionMappin();
            this.SetSelectedMappin(null);
            this.PlaySound(n"MapPin", n"OnDisable");
          } else {
            if this.selectedMappin.IsPlayerTracked() {
              this.UntrackMappin();
              this.PlaySound(n"MapPin", n"OnDisable");
            } else {
              this.UntrackCustomPositionMappin();
              this.TrackMappin(this.selectedMappin);
              this.PlaySound(n"MapPin", n"OnEnable");
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
  let dummy: wref<JournalEntry>;
  this.m_journalManager.TrackEntry(dummy);
}
