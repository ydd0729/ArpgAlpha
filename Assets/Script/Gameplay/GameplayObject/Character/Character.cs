using System;
using UnityEngine;
using UnityEngine.Serialization;
using Yd.Extension;

namespace Yd.Gameplay.Object
{
    [RequireComponent(typeof(Animator))]
    [SelectionBase]
    public class Character : Actor
    {
        [SerializeField] private GameObject controllerPrefab;
        [FormerlySerializedAs("characterData")] [SerializeField] protected CharacterData data;
        [SerializeField] private HealthBar healthBar;

        public Animator Animator { get; private set; }
        public CharacterController UnityController { get; private set; }

        public CharacterMovement Movement { get; private set; }

        public GameplayCharacterController Controller { get; private set; }

        public Rigidbody Rigidbody { get; private set; }

        public CharacterData Data => data;
        public PlayerCharacterData PlayerCharacterData => (PlayerCharacterData)Data;

        protected HealthBar HealthBar => healthBar;

        public CharacterWeapon Weapon
        {
            get;
            protected set;
        }

        public bool IsGrounded => Movement.GroundDistance <=
                                  (Movement.CurrentState.IsGroundState
                                      ? Data.GroundToleranceWhenGrounded
                                      : Data.GroundToleranceWhenFalling);


        private void Awake()
        {
            Animator = GetComponent<Animator>();

            UnityController = GetComponent<CharacterController>();
            UnityController.detectCollisions = false;

            Rigidbody = GetComponent<Rigidbody>();

            Movement = this.GetOrAddComponent<CharacterMovement>();
            Movement.Initialize(this);

            Controller = Instantiate(controllerPrefab, transform.parent).GetComponent<GameplayCharacterController>();
            // 在 Instantiate 返回前就会执行 Awake ，不是想要的，把初始化放在 Initialize 中
            Controller.Initialize(this);
        }

        private void OnAnimatorMove()
        {
            AnimatorMoved?.Invoke();
        }

        public void SetGrounded(bool isGrounded)
        {
            if (isGrounded)
            {
                UnityController.enabled = true;
                Rigidbody.isKinematic = true;
                Rigidbody.interpolation = RigidbodyInterpolation.None;
            }
            else
            {
                UnityController.enabled = false;
                Rigidbody.isKinematic = false;
                Rigidbody.interpolation = RigidbodyInterpolation.Extrapolate;
            }
        }

        public void OnHealthChanged(float health)
        {
            HealthBar.SetHealth(health);
        }

        public void OnMaxHealthChanged(float health)
        {
            HealthBar.SetMaxHealth(health);
        }

        public event Action AnimatorMoved;
    }

    public enum CharacterWeapon
    {
        None
    }
}