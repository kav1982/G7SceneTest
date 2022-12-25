using UnityEngine.Rendering.Universal;

namespace UnityEditor.Rendering.Universal
{
    [VolumeComponentEditor(typeof(Tonemapping))]
    sealed class TonemappingEditor : VolumeComponentEditor
    {
        SerializedDataParameter m_Mode;
        SerializedDataParameter m_FilmicSlope;
        SerializedDataParameter m_FilmicToe;
        SerializedDataParameter m_FilmicShoulder;
        SerializedDataParameter m_FilmicBlackClip;
        SerializedDataParameter m_FilmicWhiteClip;

        public override void OnEnable()
        {
            var o = new PropertyFetcher<Tonemapping>(serializedObject);

            m_Mode = Unpack(o.Find(x => x.mode));
            m_FilmicSlope = Unpack(o.Find(x => x.filmicSlope));
            m_FilmicToe = Unpack(o.Find(x => x.filmicToe));
            m_FilmicShoulder = Unpack(o.Find(x => x.filmicShoulder));
            m_FilmicBlackClip = Unpack(o.Find(x => x.filmicBlackClip));
            m_FilmicWhiteClip = Unpack(o.Find(x => x.filmicWhiteClip));
        }

        public override void OnInspectorGUI()
        {
            PropertyField(m_Mode);

            if (m_Mode.value.intValue == (int)TonemappingMode.UE4_ACES)
            {
                PropertyField(m_FilmicSlope);
                PropertyField(m_FilmicToe);
                PropertyField(m_FilmicShoulder);
                PropertyField(m_FilmicBlackClip);
                PropertyField(m_FilmicWhiteClip);
            }

            // Display a warning if the user is trying to use a tonemap while rendering in LDR
            var asset = UniversalRenderPipeline.asset;
            if (asset != null && !asset.supportsHDR)
            {
                EditorGUILayout.HelpBox("Tonemapping should only be used when working in HDR.", MessageType.Warning);
                return;
            }
        }
    }
}
