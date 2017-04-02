//::///////////////////////////////////////////////
//:: Freedom of Movement
//:: NW_S0_FreeMove.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The target creature gains immunity to the
    Entangle, Slow and Paralysis effects
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 29, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 21, 2001

#include "x2_inc_spellhook"
//#include "sh_classes_const"
//#include "nwnx_funcs"
//#include "sh_deity_inc"
#include "subraces"

void main()
{

/*
  Spellcast Hook Code
  Added 2003-06-23 by GeorgZ
  If you want to make changes to all spells,
  check x2_inc_spellhook.nss to find out more

*/

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

// End of Spell Cast Hook


    //Declare major variables
    object oTarget = GetSpellTargetObject();
    int nMetaMagic = GetMetaMagicFeat();
    int nDuration = GetCasterLevel(OBJECT_SELF);
    nDuration = GetThalieCaster(OBJECT_SELF,oTarget,nDuration);
    effect eParal = EffectImmunity(IMMUNITY_TYPE_PARALYSIS);
    effect eEntangle = EffectImmunity(IMMUNITY_TYPE_ENTANGLE);
    effect eSlow = EffectImmunity(IMMUNITY_TYPE_SLOW);
    effect eMove = EffectImmunity(IMMUNITY_TYPE_MOVEMENT_SPEED_DECREASE);
    effect eVis = EffectVisualEffect(VFX_DUR_FREEDOM_OF_MOVEMENT);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    //Link effects
    effect eLink = EffectLinkEffects(eParal, eEntangle);
    eLink = EffectLinkEffects(eLink, eSlow);
    eLink = EffectLinkEffects(eLink, eVis);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(eLink, eMove);

    //Fire cast spell at event for the specified target
    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_FREEDOM_OF_MOVEMENT, FALSE));
    int bSubraceSlowed = FALSE;

    //Search for and remove the above negative effects
    effect eLook = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eLook))
    {
        if(GetEffectType(eLook) == EFFECT_TYPE_PARALYZE ||
            GetEffectType(eLook) == EFFECT_TYPE_ENTANGLE ||
            GetEffectType(eLook) == EFFECT_TYPE_SLOW ||
            GetEffectType(eLook) == EFFECT_TYPE_MOVEMENT_SPEED_DECREASE)
        {
            if(Subraces_GetIsSubraceEffect(eLook)) {
              bSubraceSlowed = TRUE;
              eLook = GetNextEffect(oTarget);
              continue;
            }

            if( GetEffectSpellId(eLook) != 2002  ) // Do not remove DD effect
              RemoveEffect(oTarget, eLook);

        }
        eLook = GetNextEffect(oTarget);
    }
    //Meta-Magic Checks
    if(nMetaMagic == METAMAGIC_EXTEND)
    {
        nDuration *= 2;
    }
    if (GetClericDomain(OBJECT_SELF,1) == 24 || //DOMENA_PAVOUCI
        GetClericDomain(OBJECT_SELF,2) == 24) //DOMENA_PAVOUCI
    {
        nDuration = nDuration * 2; //Duration is +100%
    }
    if (GetHasFeat(FEAT_PROTECTION_DOMAIN_POWER))
    {
         nDuration = nDuration + nDuration / 2;
    }
    //Apply Linked Effect
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, TurnsToSeconds(nDuration));
}

