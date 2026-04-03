void main() {
  // Variables
  var name = 'Xuan Duc';
  int age = 21;
  double height = 1.7;
  bool isAdult = age > 18 ? true : false;

  // Print statements
  print('Name: $name');
  print('Age: $age');
  print('Height: $height');

  // Conditional statement
  if (isAdult) {
    print('$name is an adult.');
  } else {
    print('$name is not an adult.');
  }

  // Function call
  greet(name);

  // Loop
  for (int i = 1; i <= 5; i++) {
    print('Loop iteration $i');
    if (i == 3) {
      break;
    }
  }

  // Friends array
  List<String> friends = ['Minh', 'Huy', 'Nam', 'Khanh', 'Long'];

  // Looping through the friends array
  for (String friend in friends) {
    print('Hello, $friend!');
  }

  // Creating an object of the Person class
  Person person = Person(name, age, height);
  person.introduce();

  // Exception handling
  try {
    int result = 10 ~/ 0;
    print('Result: $result');
  } catch (e) {
    print('An error occurred: $e');
  }
}

// Function definition
void greet(String name) {
  print('Welcome to Dart Lab, $name!');
}

// Class definition
class Person {
  String name;
  int age;
  double height;
  bool isAdult;

  Person(this.name, this.age, this.height) : isAdult = age > 18;

  void introduce() {
    print(
        'My name is $name, I am $age years old and my height is $height feet.');
  }
}