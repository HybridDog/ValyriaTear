///////////////////////////////////////////////////////////////////////////////
//            Copyright (C) 2004-2011 by The Allacrost Project
//            Copyright (C) 2012-2016 by Bertram (Valyria Tear)
//                         All Rights Reserved
//
// This code is licensed under the GNU GPL version 2. It is free software
// and you may modify it and/or redistribute it under the terms of this license.
// See http://www.gnu.org/copyleft/gpl.html for details.
///////////////////////////////////////////////////////////////////////////////

/** ****************************************************************************
*** \file    audio.h
*** \author  Tyler Olsen - roots@allacrost.org
*** \author  Mois�s Ferrer Serra - byaku@allacrost.org
*** \author  Aaron Smith - etherstar@allacrost.org
*** \author  Yohann Ferreira, yohann ferreira orange fr
*** \brief   Header file for audio engine interface.
***
*** This code provides an easy-to-use API for managing all music and sounds used
*** in the game.
***
*** \note This code uses the OpenAL audio library. See http://www.openal.com/
*** ***************************************************************************/

#ifndef __AUDIO_HEADER__
#define __AUDIO_HEADER__

#include "utils/singleton.h"

#include "audio_descriptor.h"
#include "audio_effects.h"

#include <map>

//! \brief All related audio engine code is wrapped within this namespace
namespace vt_audio
{

class AudioEngine;

//! \brief The singleton pointer responsible for all audio operations.
extern AudioEngine *AudioManager;

//! \brief Determines whether the code in the vt_audio namespace should print debug statements or not.
extern bool AUDIO_DEBUG;

//! \brief Enable whether the audio engine should function
extern bool AUDIO_ENABLE;

namespace private_audio
{

//! \brief The maximum default number of audio sources that the engine tries to create
const uint16_t MAX_DEFAULT_AUDIO_SOURCES = 64;



//! \brief A container class for an element of the LRU audio cache managed by the AudioEngine class
class AudioCacheElement
{
public:
    AudioCacheElement(uint32_t time, AudioDescriptor *aud) :
        last_update_time(time), audio(aud) {}

    //! \brief Retains the time that the audio was last updated through any operation
    uint32_t last_update_time;

    //! \brief A pointer to the audio descriptor described by the cache element
    AudioDescriptor *audio;
};

} // namespace private_audio

/** ****************************************************************************
*** \brief A singleton class that manages all audio related data and operations
***
*** This class is provided as a singleton so it is conveniently accesible where needed. Here
*** there is internal control of the audio device and available sources. Interfaces for the 2
*** main groups (sound and music) are available. Also the listener funtionality is provided
*** from here.
***
*** \note Make sure to later resume paused sounds, otherwise the sources that they hold
*** will never be released
*** ***************************************************************************/
class AudioEngine : public vt_utils::Singleton<AudioEngine>
{
    friend class vt_utils::Singleton<AudioEngine>;
// friend class private_audio::SoundData;
// friend class private_audio::MusicData;
    friend class AudioDescriptor;
    friend class SoundDescriptor;
    friend class MusicDescriptor;
    friend class Effects;

public:
    ~AudioEngine();

    /** \brief Opens all audio libraries and initializes the audio device, context, and states
    *** \return True if there were no errors during initialization
    **/
    bool SingletonInitialize();

    //! \brief Updates various parts of the audio state, such as streaming buffers
    void Update();

    float GetSoundVolume() const {
        return _sound_volume;
    }

    float GetMusicVolume() const {
        return _music_volume;
    }

    /** \brief Sets the global volume level for all sounds
    *** \param volume The sound volume level to set. The valid range is: [0.0 (mute), 1.0 (max volume)]
    **/
    void SetSoundVolume(float volume);

    /** \brief Sets the global volume level for all music
    *** \param volume The music volume level to set. The valid range is: [0.0 (mute), 1.0 (max volume)]
    **/
    void SetMusicVolume(float volume);

    /** \name Global Audio State Manipulation Functions
    *** \brief Performs specified operation on all sounds and music.
    ***
    *** These functions will only effect audio data that is in the state(s) specified below:
    *** - PlayAudio()     <==>   all states but the playing state
    *** - PauseAudio()    <==>   playing state
    *** - ResumeAudio()   <==>   paused state
    *** - StopAudio()     <==>   all states but the stopped state
    *** - RewindAudio()   <==>   all states
    **/
    //@{
    void PauseAudio() {
        PauseAllSounds();
        PauseActiveMusic();
    }

    void ResumeAudio() {
        ResumeAllSounds();
        ResumeActiveMusic();
    }

    void StopAudio() {
        StopAllSounds();
        StopActiveMusic();
    }

    void RewindAudio() {
        RewindAllSounds();
        RewindActiveMusic();
    }
    //@}

    /** \name Global Sound State Manipulation Functions
    *** \brief Performs specified operation on all sounds
    **/
    //@{
    void PauseAllSounds();
    void ResumeAllSounds();
    void StopAllSounds();
    void RewindAllSounds();
    //@}

    /** \name Global Sound State Manipulation Functions
    *** \brief Performs specified operation on all sounds
    *** Since there is only one music source, these functions only affect that source.
    *** They are equivalent to calling the {Pause/Resume/Stop/Rewind}Music functions on
    *** the MusicDescriptor which currently has posession of the source.
    **/
    //@{
    void PauseActiveMusic();
    void ResumeActiveMusic();
    void StopActiveMusic();
    void RewindActiveMusic();
    //@}

    /** \name Three Dimensional Audio Properties Functions
    *** \brief Used to manipulate the shared 3D state members that all sounds share
    *** Refer to the OpenAL documentation to understand what effect each of these
    *** properties have (listener position, velocity, and orientation).
    **/
    //@{
    void SetListenerPosition(const float position[3]);
    void SetListenerVelocity(const float velocity[3]);
    void SetListenerOrientation(const float orientation[3]);

    void GetListenerPosition(float position[3]) const;
    void GetListenerVelocity(float velocity[3]) const;
    void GetListenerOrientation(float orientation[3]) const;
    //@}

    //! \name Audio Effect Functions
    //@{
    /** \brief Fades in or out every audio entry of the given type.
    *** \param time the time in ms to fade in/out.
    **/
    void FadeOutActiveMusic(float time = 1000.0f);
    void FadeInActiveMusic(float time = 1000.0f);
    void FadeOutAllSounds(float time = 1000.0f);
    //@}

    /** \brief Plays a sound once with no looping
    *** \param filename The name of the sound file to play
    *** This method of playback is useful because it doesn't require any SoundDescriptor
    *** objects to be managed by the user. This is ideal for the case of scripts which
    *** wish to play a sound only once. The sound is loaded (if necessary) into the
    *** sound cache and played from there.
    **/

    /** \brief Methods for manipulating audio contained within the audio cache
    *** \param filename The name of the sound or music file to operate on
    ***
    *** These methods invoke the named operation on the piece of audio contained
    *** within the AudioEngine's LRU audio cache. The primary intended use for these
    *** functions are for scripts which simply wish to play a sound once to indicate
    *** an event or action.
    ***
    *** The LoadSound/Music functions are not required to use, as invoking a PlaySound/Music
    *** function will automatically load the audio data if it is not inside the cache already.
    *** The play, stop, pause, and resume audio operations are the only operations that the user is
    *** provided with a direct interface to. For any other operations (rewind, seek, volume control,
    *** looping, etc.), the user must call the RetrieveSound/Music functions to obtain a pointer
    *** to the audio data and make the desired call on the AudioDescriptor object itself.
    ***
    *** \note The default parameters for audio loading (static/streaming data type, stream buffer size)
    *** can not be set nor manipulated with cached audio.
    **/
    //@{
    /** \brief Creates a new SoundDescriptor using the given filename and loads it into the audio cache
    *** \param gm The game mode owning the audio descriptor to load.
    *** \return True if the sound was loaded into the cache successfully
    **/
    bool LoadSound(const std::string &filename, vt_mode_manager::GameMode *gm = nullptr);

    /** \brief Creates a new MusicDescriptor using the given filename and loads it into the audio cache
    *** \param gm The game mode owning the audio descriptor to load.
    *** \return True if the music was loaded into the cache successfully
    **/
    bool LoadMusic(const std::string &filename, vt_mode_manager::GameMode *gm = nullptr);

    //! \brief Plays a sound that is contained within the audio cache
    void PlaySound(const std::string &filename);

    //! \brief Plays a piece of music that is contained within the audio cache
    void PlayMusic(const std::string &filename);

    //! \brief Stops a sound that is playing from within the audio cache
    void StopSound(const std::string &filename);

    //! \brief Stops a piece of music that is playing from within the audio cache
    void StopMusic(const std::string &filename) {
        StopSound(filename);
    }

    //! \brief Pauses a sound that is playing from within the audio cache
    void PauseSound(const std::string &filename);

    //! \brief Pauses a piece of music that is playing from within the audio cache
    void PauseMusic(const std::string &filename) {
        PauseSound(filename);
    }

    //! \brief Resumes a sound that has been paused from within the audio cache
    void ResumeSound(const std::string &filename);

    //! \brief Resumes a piece of music that has been paused from within the audio cache
    void ResumeMusic(const std::string &filename) {
        ResumeSound(filename);
    }

    //! \return A pointer to the SoundDescriptor contained within the cache, or nullptr if it could not be found
    SoundDescriptor *RetrieveSound(const std::string &filename);

    //! \return A pointer to the MusicDescriptor contained within the cache, or nullptr if it could not be found
    MusicDescriptor *RetrieveMusic(const std::string &filename);

    //! \returns A pointer of the active music descriptor (the one playing or ready to be played.)
    MusicDescriptor* GetActiveMusic()
    { return _active_music; }
    //@}

    /**
    *** Tells the audio engine that a game mode ended.
    *** Thus, permitting to check whether the audio descriptors owned by the mode can be freed
    *** from memory.
    **/
    void RemoveGameModeOwner(vt_mode_manager::GameMode *gm);

    /** \name Error Detection and Processing methods
    *** Code external to the audio engine should not need to make use of the following methods,
    *** as error detection is routinely done by the engine itself.
    **/
    //@{
    /** \brief Retrieves the OpenAL error code and retains it in the _al_error_code member
    *** \return True if an OpenAL error has been detected, false if no errors were detected
    **/
    bool CheckALError() {
        _al_error_code = alGetError();
        return (_al_error_code != AL_NO_ERROR);
    }

    /** \brief Retrieves the OpenAL context error code and retains it in the _alc_error_code member
    *** \return True if an OpenAL context error has been detected, false if no errors were detected
    **/
    bool CheckALCError() {
        _alc_error_code = alcGetError(_device);
        return (_alc_error_code != ALC_NO_ERROR);
    }

    ALenum GetALError() {
        return _al_error_code;
    }

    ALCenum GetALCError() {
        return _alc_error_code;
    }

    ///! \brief Returns a string representation of the most recently fetched OpenAL error code
    const std::string CreateALErrorString();

    //! \brief Returns a string representation of the most recently fetched OpenAL context error code
    const std::string CreateALCErrorString();
    //@}

    //! \brief Prints information about the audio properties and settings of the user's machine
    void DEBUG_PrintInfo();

private:
    //! \note Constructors are kept private since this class is a singleton
    //@{
    AudioEngine();
    AudioEngine(const AudioEngine &game_audio);
    //@}

    //! \brief The global volume level of all sounds (0.0f is mute, 1.0f is max)
    float _sound_volume;

    //! \brief The global volume level of all music (0.0f is mute, 1.0f is max)
    float _music_volume;

    //! \brief The OpenAL device currently being utilized by the audio engine
    ALCdevice *_device;

    //! \brief The current OpenAL context that the audio engine is using
    ALCcontext *_context;

    //! \brief Holds the most recently fetched OpenAL error code
    ALenum _al_error_code;

    //! \brief Holds the most recently fetched OpenAL context error code
    ALCenum _alc_error_code;

    //! \brief Contains the maximum number of available audio sources that can exist simultaneously
    uint16_t _max_sources;

    //! \brief The listener properties used by audio which plays in a multi-dimensional space
    //@{
    float _listener_position[3];
    float _listener_velocity[3];
    float _listener_orientation[3];
    //@}

    //! \brief A pointer to the last music descriptor which was played
    MusicDescriptor *_active_music;

    //! \brief Contains all available audio sources
    std::vector<private_audio::AudioSource *> _audio_sources;

    /** \brief Lists of pointers to all audio descriptor objects which have been created by the user
    *** These lists are kept so that when the global sound or music volume levels are changed, all
    *** sound and music objects will also have their volumes updated.
    **/
    //@{
    std::vector<SoundDescriptor *> _registered_sounds;
    std::vector<MusicDescriptor *> _registered_music;
    //@}

    /** \brief A LRU cache of audio which is managed internally by the audio engine
    *** The purpose of this cache is to allow the user to quickly and easily play
    *** sounds and music without having to maintain a Sound//MusicDescriptor object in memory.
    *** This is used, for example, by script functions which simply want to play a sound to
    *** indicate an action or event has occurred.
    ***
    *** The audio cache is a LRU (least recently used) structure, meaning that if an
    *** entry needs to be evicted or replaced to make room for another, the least
    *** recently used sound or music is deleted from the cache (as long as it is not playing).
    *** The key in the STL map is the filename for the audio contained within the cache, while
    *** the second is a container wrapping the audio descriptor pointer and the LRU time.
    **/
    std::map<std::string, private_audio::AudioCacheElement> _audio_cache;

    /** \brief Acquires an available audio source that may be used
    *** \return A pointer to the available source, or nullptr if no available source could be found
    *** \todo Add an algoihtm to give priority to some data/sounds/music over others.
    **/
    private_audio::AudioSource *_AcquireAudioSource();

    /** \brief A helper function to LoadSound and LoadMusic that takes care of the messy details of cache managment
    *** \param filename The filename of the audio to load
    *** \param is_music Tells whether the audio member to load is some music or sound object.
    *** \param The potential game mode "owning" the sound, permitting the engine to later free the sound
    *** if no more game modes own it.
    *** \return True if the audio was successfully loaded and added to the audio cache, false if it was not.
    **/
    bool _LoadAudio(const std::string &filename, bool is_music, vt_mode_manager::GameMode *gm = nullptr);

}; // class AudioEngine : public vt_utils::Singleton<AudioEngine>

} // namespace vt_audio

#endif // __AUDIO_HEADER__
