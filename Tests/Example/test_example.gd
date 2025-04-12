extends GutTest

func test_1():
	# this test will pass because 1 does equal 1
	assert_eq(1, 1)

func test_2():
	# this test will pass because 'hello' does not equal 'goodbye'
	assert_ne('hello', 'goodbye')
