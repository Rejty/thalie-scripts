//::///////////////////////////////////////////////
//:: [Harm]
//:: [NW_S0_Harm.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Reduces target to 1d4 HP on successful touch
//:: attack.  If the target is undead it is healed.
//:://////////////////////////////////////////////
//:: Created By: Keith Soleski
//:: Created On: Jan 18, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: Update Pass By: Preston W, On: Aug 1, 2001
//:: Last Update: Georg Zoeller On: Oct 10, 2004
//:://////////////////////////////////////////////

#include "NW_I0_SPELLS"
#include "x0_I0_SPELLS"
#include "x2_inc_spellhook"

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
    int nDamage, nHeal;
    int nMetaMagic = GetMetaMagicFeat();
    int nTouch = TouchAttackMelee(oTarget);
    effect eVis = EffectVisualEffect(246);
    effect eVis2 = EffectVisualEffect(VFX_IMP_HEALING_G);
    effect eHeal, eDam;
    int iCasterLevel = GetCasterLevel(OBJECT_SELF);
    iCasterLevel = GetThalieCaster(OBJECT_SELF,OBJECT_SELF,iCasterLevel,FALSE);
    int iValue = 10*(iCasterLevel);

    // Heretic
    int iHereticLevel = GetLevelByClass(31, OBJECT_SELF); // Heretic
    if(iHereticLevel > 0 && (iHereticLevel + 10) > iCasterLevel) {
      iValue = 10*(10+iHereticLevel);
    }

    if (iValue >= 250)
    {
        iValue = 250;
    }
    if ((nMetaMagic == METAMAGIC_EMPOWER) || GetHasFeat(FEAT_DESTRUCTION_DOMAIN_POWER))
    {
       iValue =  iValue+ (iValue/2);
    }
    if (GetHasFeat(1476)) //FEAT_DRUID_SPECIALIZACE_MOROVY
    {
        iValue =  iValue+ (iValue/5);
    }
    //Check that the target is undead
    if (GetRacialType(oTarget) == RACIAL_TYPE_UNDEAD)
    {
        //Figure out the amount of damage to heal
        nHeal = GetMaxHitPoints(oTarget) - GetCurrentHitPoints(oTarget);
        if (nHeal >= iValue)
        {
            nHeal = iValue;
        }
        //Set the heal effect
        eHeal = EffectHeal(nHeal);
        //Apply heal effect and VFX impact
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oTarget);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget);
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_HARM, FALSE));
    }
    else if (nTouch != FALSE)  //GZ: Fixed boolean check to work in NWScript. 1 or 2 are valid return numbers from TouchAttackMelee
    {
        if(!GetIsReactionTypeFriendly(oTarget))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_HARM));
            if (!MyResistSpell(OBJECT_SELF, oTarget))
            {

                if (!MySavingThrow(SAVING_THROW_WILL,oTarget,GetSpellSaveDC()+GetThalieSpellDCBonus(OBJECT_SELF), SAVING_THROW_TYPE_NEGATIVE, OBJECT_SELF, 1.0))
                {
                   nDamage = iValue;
                }
                else
                {
                   nDamage = iValue /2;
                }
                eDam = EffectDamage(nDamage,DAMAGE_TYPE_NEGATIVE);
                //Apply the VFX impact and effects
                DelayCommand(1.0, AssignCommand(OBJECT_SELF,ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget)));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);

            }
        }
    }
}
