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