using System;
using System.Collections.Generic;
using UnityEngine;
using Yd.Extension;

namespace Yd.Animation
{
    [Serializable]
    public enum AnimatorParameterId
    {
        None,

        // States
        Stand,
        Attack,
        Walk,
        Run,
        Jump,
        Fall,

        // Random
        RandomIndex,
        LastIndex,

        // Step
        StepLeft,
        StepRight,
        StepLeftMiddle,
        StepRightMiddle,

        GroundVelocity
    }

    [Serializable]
    public enum AnimatorParameterType
    {
        Bool,
        Int,
        Float
    }

    [Serializable]
    public struct AnimatorParameter
    {
        public AnimatorParameterId Id;
        public AnimatorParameterType Type;
        public float Value;
    }

    public static class AnimatorParameterExtension
    {
        private static Dictionary<AnimatorParameterId, int> parameterId;
        private static Dictionary<AnimatorParameterId, int> ParameterId =>
            parameterId ??= new Dictionary<AnimatorParameterId, int>();

        public static int GetAnimatorHash(this AnimatorParameterId parameter)
        {
            if (!ParameterId.TryGetValue(parameter, out var id))
            {
                id = Animator.StringToHash(parameter.GetString());
                ParameterId.Add(parameter, id);
            }

            return id;
        }
    }
}