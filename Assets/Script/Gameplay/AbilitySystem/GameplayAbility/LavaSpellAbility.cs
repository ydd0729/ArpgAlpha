using System;
using System.Threading.Tasks;
using JetBrains.Annotations;
using UnityEngine;
using Yd.Algorithm;
using Yd.Animation;
using Yd.Audio;
using Yd.Manager;

namespace Yd.Gameplay.AbilitySystem
{
    public class LavaSpellAbility : GameplayAbility
    {
        private static readonly int SpellPrepare = Animator.StringToHash("Spell Prepare");
        private static readonly int Spell = Animator.StringToHash("Spell");
        private Coroutine fireballLauncher;
        private Coroutine growlSounds;

        private bool isLaunching;

        public LavaSpellAbility(
            GameplayAbilityData data, GameplayAbilitySystem owner, [CanBeNull] GameplayAbilitySystem source
        ) : base(data, owner, source)
        {
            Tags.Add("LavaSpell");
            // Tags.Add("Attack");
        }
        private LavaSpellAbilityData SpellData => (LavaSpellAbilityData)Data;

        protected override async Task<bool> StartExecution()
        {
            if (!await base.StartExecution())
            {
                return false;
            }

            growlSounds = CoroutineTimer.SetTimer
            (
                _ => Owner.Character.AudioManager.PlayOneShot(AudioId.LavaGrowls, AudioChannel.World),
                0.5f,
                1,
                CoroutineTimerLoopPolicy.InfiniteLoop
            );

            Owner.Character.Animator.SetValue(AnimatorParameterId.Attack, true);
            Owner.Character.Animator.SetTrigger(SpellPrepare);
            
            // await Task.Delay(TimeSpan.FromSeconds(SpellData.SpellPrepareDuration));
            //
            // Owner.Character.Animator.SetBool(Spell, true);
            // isLaunching = true;
            //
            // await Task.Delay(TimeSpan.FromSeconds(SpellData.SpellDuration));
            //
            // isLaunching = false;
            // Owner.Character.Animator.SetBool(Spell, false);
            // Owner.Character.Animator.SetValue(AnimatorParameterId.Attack, false);
            // CoroutineTimer.Cancel(ref growlSounds);

            return true;
        }

        private float spellPrepareTimer = 0;
        private float spellTimer = 0;

        public override void Tick()
        {
            base.Tick();

            if (spellPrepareTimer < SpellData.SpellPrepareDuration)
            {
                spellPrepareTimer += Time.deltaTime;
            }
            else if (spellTimer < SpellData.SpellDuration)
            {
                spellTimer += Time.deltaTime;
                if (!isLaunching)
                {
                    Owner.Character.Animator.SetBool(Spell, true);
                    isLaunching = true;
                }
                if (isLaunching && fireballLauncher == null)
                {
                    fireballLauncher = CoroutineTimer.SetTimer
                    (
                        context => {
                            if (Owner == null)
                            {
                                return;
                            }

                            if (Owner.Character.Target == null)
                            {
                                return;
                            }

                            var randomInCircle = RandomE.RandomInCircle(4f);
                            var position = Owner.Character.Target.transform.position +
                                           new Vector3(randomInCircle.x, 0f, randomInCircle.y);

                            var fireball = UnityEngine.Object.Instantiate(SpellData.FireballPrefab);
                            fireball.GetComponent<LavaFireBall>().Owner = Owner.Character.gameObject;

                            fireball.transform.position = position;
                            fireball.transform.forward = position - Owner.transform.position;

                        },
                        0.8f,
                        new CoroutineTimerLoopPolicy
                        {
                            invokeImmediately = false,
                            isInfiniteLoop = true
                        }
                    );
                }
            }
            else
            {
                if (isLaunching)
                {
                    isLaunching = false;
                    Owner.Character.Animator.SetBool(Spell, false);
                    Owner.Character.Animator.SetValue(AnimatorParameterId.Attack, false);
                    CoroutineTimer.Cancel(ref growlSounds);
                }
                if (!isLaunching && fireballLauncher != null)
                {
                    CoroutineTimer.Cancel(ref fireballLauncher);
                }
            }
        }

        public override void StopExecution()
        {
            base.StopExecution();
            CoroutineTimer.Cancel(ref fireballLauncher);
            CoroutineTimer.Cancel(ref growlSounds);
            Debug.Log("Lava Spell Ability stopped.");
        }
    }
}