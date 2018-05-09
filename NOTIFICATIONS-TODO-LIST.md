## Notifications TODO List:

### Game Appointments

* [x] add tournament relationship
* [x] change opponent to reference attendee
* [x] add round model
* [x] tournaments have many rounds

### Game Appointment import

* xml parsing using nokogiri
* assign round on import

### SMS Update

* [x] change sms-opt-in to be an attribute of attendee
* migrate sms-plan to the attendee sms-opt-in attribute
* disable the plan

### Views

* [x] list appointments by round
* [x] list of rounds by tournaments
* preview notifications
* [x] one button round game appointment notifications

### SMS functions

* ability to send a stop sending sms message to go-congress app that turns off notifications
* research ability to turn off sms to specific #'s

### User Stories

* [x] A user can view and select rounds by tournament

  * Given: a tournament and round for that tournament
  * When: A user navigates to the rounds_path
  * Then: A user can see a list of rounds and select a round to view game_appointments

* A user can preview game appointment sms-notification messages before sending them

  * Given: Game Appointments List
  * When: A user clicks preview messages
  * Then: The user is shown the message to be sent

* [x] A user can send sms reminders for a tournament round's game appointments

  * Given: A round with several game appointments
  * When: A user clicks "send sms reminders"
  * Then: Texts are sent to each attendee with `receive_sms: true` with the game appointment details

* [x] A user can opt to receive sms notifications on the attendee form
  * Given: An attendee form with a receive sms option
  * When: The user fills out the form and checks the receive sms option
  * Then: The receive_sms attribute is set to true and a local phone number is required

### Refactoring TODO's:

* Move the send_sms_reminders into a workflow object
* Add an editable preview message form
* Add tests
* Improve UI
